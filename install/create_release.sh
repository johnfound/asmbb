#!/bin/bash

mkdir asmbb

# complile less files

pushd .

cd ../www/templates/Wasp/
./compile_styles.sh

cd ../Light/
./compile_styles.sh

popd

# copy engine files
cp ../www/engine asmbb/
cp ../www/*.so asmbb/

# copy images
rsync -ar ../www/images/* asmbb/images/ --exclude-from=exclude.txt

# templates and styles for Light theme
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
