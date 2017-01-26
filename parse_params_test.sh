#!/bin/bash

. parse_params_sample.sh

function startTest()
{
 
 #clear values
 config_file=""
 output_file=""
 force=""
 verbose=""
 
 inputCommand="parseParams $@"
  

 parseParams "$@"

 
}

function assertEquals()
{
   
    expected=$1
    actual=$config_file;
    
    if [ "$expected" != "$actual" ]; then
	error=true
        configMsg="Error! Config file :  EXPECTED= $expected ACTUAL= $actual"
    else
        configMsg="Config file : $actual"
    fi
    
    shift
    
    expected=$1
    actual=$output_file;
    
    if [ "$expected" != "$actual" ]; then
	error=true
        outputMsg="Error! Outpuf file :  EXPECTED= $expected ACTUAL= $actual"
    else 
	outputMsg="Output file : $actual"
    fi
    
    shift
    
    expected=$1
    actual=$force;
    
    if [ "$expected" != "$actual" ]; then
	error=true
        forceMsg="Error! Force switch :  EXPECTED= $expected ACTUAL= $actual"
    else
	forceMsg="Force switch : $actual"
    fi
    
    shift
    
    expected=$1
    actual=$verbose;
    
    if [ "$expected" != "$actual" ]; then
	error=true
        verboseMsg="Error! Verbose switch :  EXPECTED= $expected ACTUAL= $actual"
    
    else
	verboseMsg="Verbose switch : $actual"	
    fi
    
    shift
    
    
    expected_index=0;
    
    for expected_param ; do
            expected_positional[$expected_index]=$expected_param
            ((expected_index++))            
    done
    
    expected=${expected_positional[@]};
    actual=${positional[@]};
    
    if [ "$expected" != "$actual" ]; then
	error=true
        positionalMsg="Error! Positional parameters :  EXPECTED= $expected ACTUAL= $actual"
    
    else
	positionalMsg="Positional parameters: $actual"	
    fi
    
    

    if [ -z "$error" ]; then
        echo "PASSED: $inputCommand"
	



    else
        echo "FAILED: $inputCommand"
    	echo -e "\t $configMsg"
	echo -e "\t $outputMsg"
	echo -e "\t $forceMsg"
	echo -e "\t $verboseMsg"
	echo -e "\t $positionalMsg"
    fi		 

    
}

# Named parameters tests


startTest -c config.conf
assertEquals config.conf "" "" ""


startTest --config config.conf
assertEquals config.conf


startTest -c=config.conf
assertEquals config.conf "" "" ""


startTest --config=config.conf
assertEquals config.conf


startTest -c config.conf --output=output.txt
assertEquals config.conf output.txt



# Switches test

startTest -f
assertEquals "" "" "true" ""


startTest -v
assertEquals "" "" "" "true"


startTest --force
assertEquals "" "" "true" ""


startTest --verbose
assertEquals "" "" "" "true"


startTest -f -v
assertEquals "" "" "true" "true"



startTest --force --verbose
assertEquals "" "" "true" "true"


startTest --force --verbose
assertEquals "" "" "true" "true"


startTest -vf
assertEquals "" "" "true" "true"

# Positional params 


startTest first
assertEquals "" "" "" "" first 


startTest first second
assertEquals "" "" "" "" first second


startTest -- -f --verbose 
assertEquals "" "" "" "" -f --verbose

# Mixed 


startTest -fv -c config.conf --output=output.txt first second
assertEquals "config.conf" "output.txt" "true" "true" first second


startTest -fvc config.conf first second
assertEquals "config.conf" "" "true" "true" first second


startTest -fc config.conf first second
assertEquals "config.conf" "" "true" "" first second


startTest first second -vfc config.conf -o=output.txt third
assertEquals "config.conf" "output.txt" "true" "true" first second third
