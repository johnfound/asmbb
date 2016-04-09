#!/bin/bash
mkdir asmbb
mkdir asmbb/templates/
mkdir asmbb/images/
mkdir asmbb/images/favicons/

# engine files
cp ../www/engine asmbb/
cp ../www/*.so asmbb/

# the templates and style files.
cp ../www/*.css asmbb/
cp ../www/templates/*.tpl asmbb/templates/
cp ../www/images/*.* asmbb/images/
cp ../www/images/favicons/*.* asmbb/images/favicons/

# example config files for apache and lighttpd
cp .htaccess asmbb/
cp lighttpd.conf asmbb/

cp ../License.txt asmbb/
cp install.txt asmbb/

# now pack it
tar -czf asmbb.tar.gz asmbb/

rm asmbb/templates/*
rmdir asmbb/templates/

rm asmbb/images/favicons/*
rmdir asmbb/images/favicons/

rm asmbb/images/*
rmdir asmbb/images/

rm asmbb/*
rm asmbb/.htaccess
rmdir asmbb
