#!/bin/bash

. parse_params_sample.sh


testCount=0;
testPassed=0;
testFailed=0;

function arrangeTest
{
    testDescription="$1"


    #clear values
    config_file=""
    output_file=""
    force=""
    verbose=""

    error=""
    configMsg=""
    outputMsg=""
    forceMsg=""
    verboseMsg=""
}


function actTest()
{

 ((testCount++)) 

 testCase="parseParams $@"

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
	    ((testPassed++)) 
        echo -e "\e[32mPASSED:\e[39m $testCase"
        return 0
    else
	    ((testFailed++)) 

        echo -e "\e[31mFAILED:\e[39m $testCase"

        if [ -n "$testDescription" ]; then
            echo -e "\e[33mDescription: $testDescription \e[39m"
        fi

    	echo -e "\t $configMsg"
	    echo -e "\t $outputMsg"
	    echo -e "\t $forceMsg"
	    echo -e "\t $verboseMsg"
	    echo -e "\t $positionalMsg"
        return 1
    fi		 

    
}


function runTests()
{

# Named parameters tests

arrangeTest "Simple test with one named parameter in short form"
actTest -c config.confd
assertEquals config.conf "" "" ""

arrangeTest
actTest --config config.confd
assertEquals config.conf


arrangeTest
actTest -c=config.conf
assertEquals config.conf "" "" ""


arrangeTest
actTest --config=config.conf
assertEquals config.conf


arrangeTest
actTest -c config.conf --output=output.txt
assertEquals config.conf output.txt



# Switches test

arrangeTest
actTest -f
assertEquals "" "" "true" ""


arrangeTest
actTest -v
assertEquals "" "" "" "true"


arrangeTest
actTest --force
assertEquals "" "" "true" ""


arrangeTest
actTest --verbose
assertEquals "" "" "" "true"


arrangeTest
actTest -f -v
assertEquals "" "" "true" "true"



arrangeTest
actTest --force --verbose
assertEquals "" "" "true" "true"


arrangeTest
actTest --force --verbose
assertEquals "" "" "true" "true"


arrangeTest
actTest -vf
assertEquals "" "" "true" "true"

# Positional params 

arrangeTest
actTest first
assertEquals "" "" "" "" first 


arrangeTest
actTest first second
assertEquals "" "" "" "" first second


arrangeTest
actTest -- -f --verbose 
assertEquals "" "" "" "" -f --verbose

# Mixed 


arrangeTest
actTest -fv -c config.conf --output=output.txt first second
assertEquals "config.conf" "output.txt" "true" "true" first second


arrangeTest "Named parameter concatenated with switches"
actTest -fvc config.conf first second
assertEquals "config.conf" "" "true" "true" first second


arrangeTest
actTest -fc config.conf first second
assertEquals "config.conf" "" "true" "" first second


arrangeTest "Positional parameters mixed with named parameters"
actTest first second -vfc config.conf -o=output.txt third
assertEquals "config.conf" "output.txt" "true" "true" first second third

}

function reportResults()
{
    echo 
    echo "------------------------"
    echo 

    if [ "$testCount" == "$testPassed" ]; then
        echo -e "\e[32mAll $testCount tests passed."
        return 0
    else
        echo -e "\e[31mSome tests failed." 
        echo -e "\t \e[32mPassed: $testPassed"
        echo -e "\t \e[31mFailed: $testFailed"
        return 1
    fi
    
}


runTests 

reportResults

exit $?


