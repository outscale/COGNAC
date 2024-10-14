#!/bin/bash

# check if $1 is valide, if $2 is present, remove invalide file

test=$(json-search -sn Request $1 | json-search -n properties)
test_ret=$?

if [ "$test_ret" == "1" -o "$test" == "null" ]; then
    echo "$1 is invalide" >&2
    if [ "$#" -gt 1 ]; then
	rm $1
    fi
fi


