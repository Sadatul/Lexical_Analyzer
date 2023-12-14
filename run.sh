#!/bin/bash

filename=$1
cppfile="${filename%.*}"
# echo $cppfile

mkdir -p ./output
flex -o ./output/$cppfile.cpp $1 
g++ ./output/$cppfile.cpp -lfl -o ./output/$cppfile.out
./output/$cppfile.out $2
