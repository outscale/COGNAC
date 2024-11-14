#!/bin/bash

# check if $1 is valide, if $2 is present, remove invalide file
config_path=$(realpath $(dirname $0))/../config.sh

shopt -s expand_aliases
source $config_path

if [ -z "${FUNCTION_SUFFIX}" ]; then
    test=$(json-search -n properties $1)
    test_ret=$?
else
    test=$(json-search -sn ${FUNCTION_SUFFIX} $1 | json-search -n properties)
    test_ret=$?
fi

if [ "$test_ret" == "1" -o "$test" == "null" ]; then
    echo "$1 is invalide" >&2
    if [ "$#" -gt 1 ]; then
	rm $1
    fi
fi


