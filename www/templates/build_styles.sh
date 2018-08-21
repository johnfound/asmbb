#!/usr/bin/bash

cd Light
echo "Compile Light/"
./compile_styles.sh

cd ../Wasp
echo "Compile Wasp/"
./compile_styles.sh

cd ../mobile
echo "Compile mobile/"
./compile_styles.sh

cd ../MoLight
echo "Compile MoLight/"
./compile_styles.sh

cd ../Terminal
echo "Compile Terminal/"
./compile_styles.sh
