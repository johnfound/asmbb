#!/usr/bin/bash

for file in ./*.less
do
  echo "Compile $file --> ${file%.*}.css"
  clessc "$file" -o "${file%.*}.css"

done
