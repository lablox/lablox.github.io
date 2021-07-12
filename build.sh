#!/bin/bash

set -e


404md2html () {
cp $maindir/404.css .
pandoc -f markdown-auto_identifiers -t html5 --lua-filter=$maindir/builder/auto_identifiers_underscore.lua 404.md -o 404_body.html
m4 $maindir/builder/404_prem4.html > 404_m4ed.html
html-minifier -c $maindir/builder/html-minifier.conf 404_m4ed.html > 404.html
rm 404_body.html 404_m4ed.html 404.css 404.md
}

md2html () {
cp $maindir/main.css .
name=$(echo $1 | cut -d'.' -f1)
pandoc -f markdown-auto_identifiers -t html5 --lua-filter=$maindir/builder/auto_identifiers_underscore.lua $1 -o body.html
cat $1 | head -n1 | sed -E "s|^#\s||g;s|\s$||g" > title
cat $maindir/builder/header.html body.html $maindir/builder/footer.html | m4 > $name-premini.html
html-minifier -c $maindir/builder/html-minifier.conf $name-premini.html > $name.html
rm body.html $name-premini.html title main.css $1
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
        if [[ $obj = "404.md" ]]
        then
           404md2html
        else
           md2html $obj
        fi
    fi
done
}

maindir=$(pwd)
stylelint ./builder/main.css --config ./builder/stylelint.json || exit 1
postcss --use cssnano -o ./main.css ./builder/main.css
stylelint ./builder/404.css --config ./builder/stylelint.json || exit 1
postcss --use cssnano -o ./404.css ./builder/404.css
rm -rf docs
cp -r markdown docs
cd docs
recursivemd2html
cd $maindir
cp ./builder/imorty.png docs
rm main.css 404.css
