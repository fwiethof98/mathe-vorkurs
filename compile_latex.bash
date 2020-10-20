#!/bin/bash
directory=$(pwd)
rm chapters/__latexindent_temp.tex
ls chapters/*.tex | awk '{printf "\\input{%s}\n", $1}' > _chapters.tex

counter=0
while [ ! -d ./structure ]; do
    cd ..
    counter=$(( $counter + 1 ))
    if [ $counter -ge 10 ]; then
        cd directory
        echo "Did you forget the structure-folder?"
        exit 1
    fi
done

buildlatex() {
    pdflatex "$1"
    makeindex "$1"
    makeglossaries "$1"
    biber "$1"
    pdflatex "$1"
    pdflatex "$1"
}

all_aux=("aux" "bbl" "bcf" "blg" "idx" "ilg" "ind" "ist" "lof" "log" "lot" "out" "sig" "slo" "sls" "tdn" "tld" "tlg" "toc" "xml")

cleanup() {
    if [ ! -d ./backup ]; then
        mkdir backup
    fi
    
    cp "$1.tex" "./backup/$1.tex"

    if [ ! -d ./auxiliary ]; then
        mkdir auxiliary
    fi
    # cd aux
    # for file in $(find . -name "$1.*"); do
    #     cp ../$file $file
    #     rm ../$file
    # done

    # if [ -f "$1.pdf" ]; then
    #     for file in "$1.pdf"; do
    #         mv "$file" "../$file"
    #     done
    # fi
    # cd ..

    rm -r ./aux/*
    for name in ${all_aux[@]}; do
        files=$(find . -name "*.$name")
        for file in $files; do
            mv $file "./auxiliary/$file"
        done
    done
}

build_files=$(find . -maxdepth 1 -name "*.tex")
for file in $build_files; do
    if [[ $file != "./_chapters.tex" ]]; then
         build_file=$file
         break
    fi
done

buildlatex "$build_file"
cleanup "$build_file"

if [ -d chapters ];then
    cd chapters
    files=$(find . -name "*.aux")

    if [ ! -d aux ]; then
        mkdir aux
    fi

    for file in $files; do
        if [ -f "./auxiliary/$file" ]; then
            mv $file "./auxiliary/$file"
        fi
    done

    cd ../
fi

python3 bot.py
