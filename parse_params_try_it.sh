#!/bin/bash

. parse_params_sample.sh

parseParams "$@"

echo "Named parameters:"
echo "configfile=$config_file"
echo "outputfile=$output_file"
echo "force=$force"
echo "verbose=$verbose"

echo "Positional parameters:"
for i in "${positional[@]}"; do 
	echo "$i" 
done
