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

cd ../Modern
echo "Compile Modern/"
./compile_styles.sh

cd ../"Urban Sunrise"
echo "Compile Urban Sunrise/"
./compile_styles.sh
