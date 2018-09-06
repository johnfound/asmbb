#!/bin/bash

#First compile the binary files

mkdir asmbb

# complile less files

pushd .

echo "Compile Wasp theme styles..."
cd ../www/templates/Wasp/
./compile_styles.sh

echo "Compile Light theme styles..."
cd ../Light/
./compile_styles.sh

echo "Compile mobile theme styles..."
cd ../mobile/
./compile_styles.sh

echo "Compile MoLight theme styles..."
cd ../MoLight/
./compile_styles.sh

popd

pushd .

cd ../musl_sqlite/
./build

popd

# copy engine files
cp ../www/engine asmbb/
cp ../musl_sqlite/*.so asmbb/

# copy images
rsync -ar ../www/images/* asmbb/images/ --exclude-from=exclude.txt

# templates and styles
rsync -ar ../www/templates/* asmbb/templates/ --exclude-from=exclude.txt

# example config files for apache and lighttpd
cp .htaccess asmbb/
cp lighttpd.conf asmbb/

cp ../License.txt asmbb/
cp ../manifest.uuid asmbb/
cp install.txt asmbb/

# now pack it
tar -czf asmbb.tar.gz asmbb/
tar -czf unpack.tar.gz unpack/

rm -rf asmbb/
