#!/bin/bash

set -e


404md2html () {
pandoc -f markdown-auto_identifiers -t html5 --lua-filter=$maindir/builder/auto_identifiers_underscore.lua 404.md -o 404_body.html
m4 $maindir/builder/404_prem4.html > 404_m4ed.html
html-minifier -c $maindir/builder/html-minifier.conf 404_m4ed.html > 404.html
rm 404_body.html 404_m4ed.html 404.css 404.md
}

md2html () {
name=$(echo $1 | cut -d'.' -f1)
pandoc -f markdown-auto_identifiers -t html5 --lua-filter=$maindir/builder/auto_identifiers_underscore.lua $1 -o body.html
cat $1 | head -n1 | sed -E "s|^#\s||g;s|\s$||g" > title
cat $maindir/builder/$2 body.html $maindir/builder/footer.html | m4 > $name-premini.html
html-minifier -c $maindir/builder/html-minifier.conf $name-premini.html > $name.html
rm body.html $name-premini.html title $1 $3
}

recursivemd2html () {
for obj in $(ls -fA1)
do
    if [[ -d $obj ]]
    then
        cd $obj
        recursivemd2html
        cd ..
    else
        md2html $obj page_header.html $maindir/page.css
    fi
done
}

lintmini () {
stylelint ./builder/$1 --config ./builder/stylelint.json || exit 1
postcss --use cssnano -o ./$1 ./builder/$1
}

maindir=$(pwd)
lintmini page.css
lintmini home.css
lintmini 404.css
rm -rf docs
cp -r markdown docs
mkdir h404
mv docs/index.md docs/404.md h404
mv home.css 404.css h404
cd h404
md2html index.md home_header.html home.css
404md2html
cat h404/index.html
cat h404/404.html
cd ../docs
recursivemd2html
cd $maindir
mv h404/index.html h404/404.html docs
cp ./builder/imorty.png docs
rm -rf h404
