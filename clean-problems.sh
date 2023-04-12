#!/bin/bash


pwdd=$(pwd)


shopt -s extglob

for dir in $pwdd/problem-generators/backup-propositional/vanilla/puzzle-mnist-3-3/*/
do
    current_dir=${dir%*/}
    

    cd $current_dir

    
    #rm !(goal.png|init.png) 
    find . -type f -not -name '*.png' -delete
    find . -type f -name 'ama3*' -delete
    #rm 'ama3*'

    cd ..





done

shopt -u extglob

cd $pwdd