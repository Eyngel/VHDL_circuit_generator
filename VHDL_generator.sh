#!/bin/bash

#Argument check:
if (($# < 1)); then
	echo "Se requieren argumentos adicionales:"

else

#Arguments:
	name=$1     #file directory
	inputs=$2   #n inputs
	outputs=$3  #n outputs

#Directory and file:
    ls
    if [ ! -d "./VHDL" ]; then
        mkdir -p VHDL
    fi   
    file="./Vector/"$name
	if [ -f "$file" ]; then     #if file exists
	    echo "Abriendo $file"
        save="./VHDL/"$name".vhd"
        touch "$save"

#Information extraction loop:
        it=0
        declare -a sig_n
        declare -a n_op
        declare -a n_out
        declare -a n_in1
        declare -a n_in2
        capa=0
        n=0
        count=0
	    while IFS=' ' read -r operation output input1 input2    
        #read line spliting into spaces
	    do
	        #echo "$operation $output $input1 $input2"
            n_op[count]=$operation
            n_out[count]=$output
            n_in1[count]=$input1
            n_in2[count]=$input2
            ((count++))
            if [ $operation = "-" ]; then
                sig_n[capa]=$n
                n=0
                ((capa++))
                ((it++))            
            else
                ((n++))
            fi
	    done <"$file"
        echo "Capas = $it"

    #Signal accondition for up to 26^2 it (10e191 inputs)
        count=0
        declare -a threat

        while [ $it -ge $count ]
        do
            for a in {a..z}
            do
                if [ $it -gt 26 ]; then
                    for b in {a..z}
                    do
                        #echo "$a$b"
                        threat[count]=$a$b
                        ((count++))
                        if [ $it -eq $count ]; then
                            break 3;
                        fi
                    done
                elif [ $it -eq $count ]; then
                    break 2;
                else
                    #echo "$a"
                    threat[count]=$a
                    ((count++))
                fi                
            done
        done

#File writing:

    #Libraries:
	    printf "library IEEE;\nuse IEEE.STD_LOGIC_1164.all;\nuse IEEE.NUMERIC_STD.all;\n" >> "$save"    #Only required
        printf "\nentity "$name" is" >> $save
        printf "\n\tport\t(" >> $save

    #PORT:
        for IN in $(seq 0 $(($inputs - 1)));
        do
            printf "\n\t\t\tIN"$IN"\t:\tin std_logic;" >> $save  
        done    
        for OUT in $(seq 0 $(($outputs - 1)));
        do
            if [ $OUT -ne $(($outputs - 1)) ]; then
                printf "\n\t\t\tOUT"$OUT"\t:\tout std_logic;" >> $save
            else
                printf "\n\t\t\tOUT"$OUT"\t:\tout std_logic);" >> $save     
            fi  
        done
        printf "\nend entity $name;" >> $save 

    #ARCHITECTURE:
        arch_name=$name"_arch"
        printf "\n\narchitecture $arch_name of "$name" is" >> $save
        
        #Signals (bus generator)
        s=0
        for i in ${threat[@]}
        do            
            elem=`expr ${sig_n[s]} - 1`
            printf "\n\tsignal "$i" : std_logic_vector("$elem" downto 0);" >> $save
            ((s++))        
        done
   
        #Process
        printf "\n\nbegin" >> $save
        capa=0
        i=0
        while [ $(($capa + 1)) -le $it ]
        do
            while [ "${n_op[i]}" != "-" ]
            do
                IN_1=" IN${n_in1[i]}"
                IN_2=" IN${n_in2[i]}"
                OUT=" OUT${n_out[i]}"
                in1=" ${threat[$(($capa - 1))]}(${n_in1[i]})"
                in2=" ${threat[$(($capa - 1))]}(${n_in2[i]})"
                out=" ${threat[$capa]}(${n_out[i]})"
                #Logic gate assignation:
                case ${n_op[i]} in
                    0)  op=" AND"
                    ;;
                    1)  op=" OR"
                    ;;
                    2)  op=" NAND"
                    ;;
                    3)  op=" NOR"
                    ;;
                    4)  op=" XOR"
                    ;;
                    5)  op=" XNOR"
                    ;;
                    6)  unset op
                        unset in2
                        unset IN_2  
                    ;;
                    7)  op=" NOT"
                        unset in2
                        unset IN_2
                    ;;   
                esac
                #Operation typing:
                if [ $it -eq 1 ];then
                    printf "\n\t$OUT <=$IN_2$op$IN_1;" >> $save
                else                
                    if [ $capa -eq 0 ]; then
                        printf "\n\t$out <=$IN_2$op$IN_1;" >> $save 
                    elif [ $capa -eq $(($it - 1)) ]; then
                        printf "\n\t$OUT <=$in2$op$in1;" >> $save
                    else
                        printf "\n\t$out <=$in2$op$in1;" >> $save
                    fi  
                fi
                ((i++))
            done
                printf "\n" >> $save
                ((capa++))
                ((i++))
        done
        printf "end $arch_name;" >> $save
    else
        echo "No existe el archivo"
    fi
fi
