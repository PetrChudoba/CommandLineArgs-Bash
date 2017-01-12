#!/bin/bash

function parseParams()
{

# The positional parameters are zero based
index=0;

while [[ $# > 0 ]]; do
    # Current parameter
    param="$1"
        
    # If named parameters terminated
    if [ x"$param" = x"--" ]; then
        shift
        # Put all reamaining to positional array
        for pos_param ; do
            positional[$index]=$pos_param
            ((index++))            
        done
        
        break # All parameters parsed
    fi
        
        
    # Parse current parameter
    while [ x"$param" != x"-" ] ; do
        case "$param" in
        
            # ======= Named parameters =======
            -c=* | --config=* )
                    config_file="${param#*=}"
                    break
                    ;;
            -c* | --config )
                    config_file="$2"
                    shift
                    break
                    ;;
            
            -o=* | --output=* )
                    output_file="${param#*=}"
                    break
                    ;;
            -o* | --output )
                    output_file="$2"
                    shift
                    break
                    ;;
                    
            # ======= Switches             
            -f* )
                    force=true
                    param="-${param:2}"
                    ;;
            --force )
                    force=true
                    break
                    ;;
            
            -v* )
                    verbose=true
                    param="-${param:2}"
                    ;;
            --verbose )
                    verbose=true
                    break
                    ;;
                        
             # ======= Positional parameters =======
            * )
                    positional[$index]=$param
                    ((index++))
                    break
                    ;;
        esac
                
                
    done
    # Done with that parameter. Move to next
    shift
done


}

function newTest()
{
 msg=$1
 
 #clear values
 config_file=""
 output_file=""
 force=""
 verbose=""
 
}

function assertEquals()
{
    echo "$msg"
	echo "parseParams $@"
    expected=$1
    actual=$config_file;
    
    if [ "$expected" != "$actual" ]; then
        echo "Error! Config file :  EXPECTED=$expected ACTUAL=$actual"
    fi
    
    shift
    
    expected=$1
    actual=$output_file;
    
    if [ "$expected" != "$actual" ]; then
        echo "Error! Outpuf file :  EXPECTED=$expected ACTUAL=$actual"
    fi
    
    shift
    
    expected=$1
    actual=$force;
    
    if [ "$expected" != "$actual" ]; then
        echo "Error! Force switch :  EXPECTED=$expected ACTUAL=$actual"
    fi
    
    shift
    
    expected=$1
    actual=$verbose;
    
    if [ "$expected" != "$actual" ]; then
        echo "Error! Verbose switch :  EXPECTED=$expected ACTUAL=$actual"
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
        echo "Error! Positional parameters :  EXPECTED=$expected ACTUAL=$actual"
    fi
    
    
    
}

# Named parameters tests

newTest "One named param short version"
parseParams -c config.conf
assertEquals config.conf "" "" ""

newTest "One named param long version"
parseParams --config config.conf
assertEquals config.conf

newTest "One named param short version with = "
parseParams -c=config.conf
assertEquals config.conf "" "" ""

newTest "One named param long version with ="
parseParams --config=config.conf
assertEquals config.conf

newTest "Two named params"
parseParams -c config.conf --output=output.txt
assertEquals config.conf output.txt



# Switches test
newTest "One switch short: -f"
parseParams -f
assertEquals "" "" "true" ""

newTest "One switch short: -v"
parseParams -v
assertEquals "" "" "" "true"

newTest "One switch long: --force"
parseParams --force
assertEquals "" "" "true" ""

newTest "One switch long: --verbose"
parseParams --verbose
assertEquals "" "" "" "true"

newTest "Two switches short: -f -v"
parseParams -f -v
assertEquals "" "" "true" "true"


newTest "Two switches long: --force --verbose"
parseParams --force --verbose
assertEquals "" "" "true" "true"

newTest "Two switches concat: -fv"
parseParams --force --verbose
assertEquals "" "" "true" "true"


newTest "Two switches reverse concat: -vf"
parseParams -vf
assertEquals "" "" "true" "true"

# Positional params 

newTest "One positinal param"
parseParams first
assertEquals "" "" "" "" first 

newTest "Two positinal param"
parseParams first second
assertEquals "" "" "" "" first second

newTest "Tricky positional params : -- -f --verbose"
parseParams -- -f --verbose 
assertEquals "" "" "" "" -f --verbose

# Mixed 

newTest "Standard case full"
parseParams -fv -c config.conf --output=output.txt first second
assertEquals "config.conf" "output.txt" "true" "true" first second

newTest "All params max concat"
parseParams -fvc config.conf first second
assertEquals "config.conf" "" "true" "true" first second


newTest "Switch + named concat"
parseParams -fc config.conf first second
assertEquals "config.conf" "" "true" "" first second

newTest "Positional parameters first"
parseParams first second -vfc config.conf -o=output.txt third
assertEquals "config.conf" "output.txt" "true" "true" first second third
