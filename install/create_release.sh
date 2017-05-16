#!/bin/bash

mkdir asmbb

mkdir asmbb/templates/
mkdir asmbb/templates/.images/
mkdir asmbb/templates/.images/emoticons/
mkdir asmbb/templates/.images/chatemoticons/

mkdir asmbb/templates/Light/
mkdir asmbb/templates/Light/.images/
mkdir asmbb/templates/Light/.images/emoticons/
mkdir asmbb/templates/Light/.images/chatemoticons/

mkdir asmbb/templates/Wasp/
mkdir asmbb/templates/Wasp/.images/
mkdir asmbb/templates/Wasp/.images/emoticons/
mkdir asmbb/templates/Wasp/.images/chatemoticons/

mkdir asmbb/images/
mkdir asmbb/images/favicons/

# complile less files

cd ../www/templates/
./compile_styles.sh

cd Wasp/
./compile_styles.sh

cd ../Light/
./compile_styles.sh

cd ../../../install/

# engine files
cp ../www/engine asmbb/
cp ../www/*.so asmbb/

# the templates and style files for the default theme.
cp ../www/templates/*.css asmbb/templates/
cp ../www/templates/*.tpl asmbb/templates/

# templates and styles for Light theme
cp ../www/templates/Light/*.css asmbb/templates/Light/
cp ../www/templates/Light/*.tpl asmbb/templates/Light/

# templates and styles for Wasp theme
cp ../www/templates/Wasp/*.css asmbb/templates/Wasp/
cp ../www/templates/Wasp/*.tpl asmbb/templates/Wasp/

# images

cp ../www/images/favicon.ico asmbb/images/
cp ../www/images/favicons/*.* asmbb/images/favicons/

# default skin
cp ../www/templates/.images/*.* asmbb/templates/.images/
cp ../www/templates/.images/emoticons/*.* asmbb/templates/.images/emoticons/
cp ../www/templates/.images/chatemoticons/*.* asmbb/templates/.images/chatemoticons/

# Wasp skin
cp ../www/templates/Wasp/.images/*.* asmbb/templates/Wasp/.images/
cp ../www/templates/Wasp/.images/emoticons/*.* asmbb/templates/Wasp/.images/emoticons/
cp ../www/templates/Wasp/.images/chatemoticons/*.* asmbb/templates/Wasp/.images/chatemoticons/

# Light skin
cp ../www/templates/Light/.images/*.* asmbb/templates/Light/.images/
cp ../www/templates/Light/.images/emoticons/*.* asmbb/templates/Light/.images/emoticons/
cp ../www/templates/Light/.images/chatemoticons/*.* asmbb/templates/Light/.images/chatemoticons/

# example config files for apache and lighttpd
cp .htaccess asmbb/
cp lighttpd.conf asmbb/

cp ../License.txt asmbb/
cp ../manifest.uuid asmbb/
cp install.txt asmbb/

# now pack it
tar -czf asmbb.tar.gz asmbb/

rm -rf asmbb/
