#!/bin/bash

find * -name "*.ko" > 1.txt
mkdir 3.4.39_zero
cat ./1.txt | while read line
do
    cp $line ./3.4.39_zero
done 
