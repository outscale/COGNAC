#!/bin/bash

e=$1
e=${e:8}

echo $(cut -s -d "/" -f2- <<< "$e") | tr -d '\n'
