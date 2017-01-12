#!/bin/bash

# Template for parsing command line parameters using only shell.


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
                    
            # ======= Switches             
            -f* )
                    force=true
                    param="-${param:2}"
                    ;;
            --force )
                    force=true
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

