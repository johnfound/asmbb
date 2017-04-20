#!/bin/bash
mkdir asmbb
mkdir asmbb/templates/
mkdir asmbb/templates/Light/
mkdir asmbb/templates/Wasp/
mkdir asmbb/images/
mkdir asmbb/images/favicons/

# complile less files

clessc ../www/templates/styles.less -o ../www/templates/all.css
clessc ../www/templates/Light/styles.less -o ../www/templates/Light/all.css
clessc ../www/templates/Wasp/styles.less -o ../www/templates/Wasp/all.css

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
cp ../www/images/*.* asmbb/images/
cp ../www/images/favicons/*.* asmbb/images/favicons/

# example config files for apache and lighttpd
cp .htaccess asmbb/
cp lighttpd.conf asmbb/

cp ../License.txt asmbb/
cp ../manifest.uuid asmbb/
cp install.txt asmbb/

# now pack it
tar -czf asmbb.tar.gz asmbb/

rm asmbb/templates/Light/*
rmdir asmbb/templates/Light/

rm asmbb/templates/Wasp/*
rmdir asmbb/templates/Wasp/

rm asmbb/templates/*
rmdir asmbb/templates/

rm asmbb/images/favicons/*
rmdir asmbb/images/favicons/

rm asmbb/images/*
rmdir asmbb/images/

rm asmbb/*
rm asmbb/.htaccess
rmdir asmbb
