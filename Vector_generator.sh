#!/bin/bash

#Argument check:
if (($# < 3)); then
	echo "Se requieren argumentos adicionales:"
    echo "Nombre Inputs Outputs"
elif [ $3 -eq 0 ]; then
    echo "Output no puede ser 0"
else

#Arguments:
	name=$1     
	inputs=$2
	outputs=$3
	#level=$4   #Abstraction level

#Directory and file:
    if [ ! -d "./Vector" ]; then     #Creates circuit folder
        mkdir -p Vector
    fi
    cd Vector           #Enter working directory 
    archivo="$name"     #Set vector file name
    
    count=1
    while [ -f "$archivo" ]     #Renames if exists
        do 
            archivo=$name"_"$count
            ((count++))
    done
    touch "$archivo"        #Creates file

#Vector generation:
    if [ $inputs -ge $outputs ]; then        #Only if inputs > outputs
        
        entrada=$inputs
        salida=0        
        
        while [ $entrada -gt $outputs ]        
        do

        #Declarations:
            bin_input=`expr $entrada - 1`                           #Inputs from 0
            declare -a array=($(seq 0 1 $bin_input))                #From 0 to Input -1
            array=($(shuf -e "${array[@]}"))                        #Suffle randomly
        
            salida=0 

        #Circuit data:
            echo "Bits del bus = ${#array[@]}"
            echo "Total de outputs = $outputs"            
            impar=`expr $entrada % 2`                                   #Parity check
            echo "Paridad = $impar"
            logic_gates=`expr $entrada / 2`                             #Nº logic gates
            echo "Logic gates (2 inputs) = $logic_gates"                  
            algorith=`expr $ejecucion + $impar`                         #Recursivity of algorith
            rama_actual=$(echo "scale=1; l($entrada)/l(2)" | bc -l)     #Current branch
            echo "Rama actual = ${rama_actual%.*}"
            rama_final=$(echo "scale=1; l($outputs)/l(2)" | bc -l)      #Final branch
            echo "Rama final = ${rama_final%.*}"
            close=`expr ${rama_actual%.*} - ${rama_final%.*}`
            echo "Ejecuciones restantes = $close"
            ejecc=`expr $entrada - $outputs`
            echo "LG. ejecc = $ejecc"

        #Main algorith:
            for ((c=0; c<${#array[@]}; c++))
            do  
                operator=$((RANDOM % 6))                #6 logic gates
                limite=`expr ${#array[@]} - $c`         #When only 1 gate remaining

                if [[ $limite -eq 1 || 
                    ( $close -le 1 &&
                      $ejecc -eq 0 ) ]]; then           #NOT / BUFF gate if odd input
                    if [ $operator -lt 2 ]; then
                        operator=6                  #BUFF                  
                    else                    
                        operator=7                  #NOT
                    fi
                        echo "$operator $salida ${array[c]}"
                        echo "$operator $salida ${array[c]}" >> $archivo           
                else
                    echo "$operator $salida ${array[c]} ${array[c+1]}"
                    echo "$operator $salida ${array[c]} ${array[c+1]}" >> $archivo
                    ((ejecc--)) 
                    ((c++))                
                fi            
                ((salida++))         
            done
        echo "-" >> $archivo
        entrada=$salida
        echo "-----------------------------------"
        done
    else
        echo "Inputs debe ser mayor que outputs"
        break 3;
    fi
    echo "END"
    echo "END" >> $archivo

#Access VHDL script
    cd ..

    if [ -f "./VHDL_generator.sh" ]; then 
        chmod +x VHDL_generator.sh
        ./VHDL_generator.sh "$archivo" "$inputs" "$outputs"
    else
        echo "No se encuentra VHDL_generator.sh"
    fi
fi




