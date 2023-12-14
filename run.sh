#!/bin/bash

filename=$1
cppfile="${filename%.*}"
# echo $cppfile

mkdir -p ./output
flex -o ./output/$cppfile.c $1 
g++ ./output/$cppfile.c -lfl -o ./output/$cppfile.out
./output/$cppfile.out $2
