#!/bin/bash

# Template for parsing command line parameters using only straight bash without getopt[s].


# The positional parameters are zero based
index=0;

while [[ $# > 0 ]]; do
    # Current parameter
	param="$1"
    
    # If named parameters termination
    if [ x"$param" = x"--" ]; then
            shift
            echo "$param"
            # Put all to positional parameters array
            for param ; do
                echo "$index"
                echo "$param"
                positional[$index]=$param
                ((index++))            
            done
            break
    fi
    
    
    # Parse current parameter
    while [ x"$param" != x"-" ] ; do
            case "$param" in
                    # ======= Named parameters =======
			
                    # Config
                    -c=* | --config=* )
                            config_file="${param#*=}"
                            break
                            ;;
                    -c* | --config )
                            config_file="$2"
                            shift
                            break
                            ;;
                    # Output
                     -o=* | --output=* )
                            output_file="${param#*=}"
                            break
                            ;;
                    -o* | --output )
                            output_file="$2"
                            shift
                            break
                            ;;
                    
                    # ======= Switches ======= 
                    
                    # Force
                    -f* )
                            force=true
                            param="-${param:2}"
                            ;;
                    --force )
                            force=true
                            break;
                            ;;
                            
                    # Verbose
                    -v* )
                            verbose=true
                            param="-${param:2}"
                            ;;
                    --verbose )
                            verbose=true
                            break;
                            ;;
                    
                    # ======= Positional parameters =======
                    * )
                            positional[$index]=$param
                            ((index++))
                            break
                            ;;
            esac
            
            
    done
    # Done with that param. move to next
    shift
done



echo "Named parameters:"
echo "configfile=$config_file"
echo "outputfile=$output_file"
echo "force=$force"
echo "verbose=$verbose"

echo "Positional parameters:"
for i in "${positional[@]}"; do 
    echo "$i" 
done
