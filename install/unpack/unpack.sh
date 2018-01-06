#!/bin/bash

tar -xvzf asmbb.tar.gz > /dev/null
mv asmbb/* ./
mv asmbb/.htaccess ./
rmdir asmbb

echo "Options  ExecCGI" > .htaccess
echo "FcgidWrapper "$PWD/engine" virtual" >> .htaccess
echo "SetHandler fcgid-script" >> .htaccess

rm asmbb.tar.gz
rm unpack.sh

echo "Status: 302 Found"
echo "Location: /"
echo
