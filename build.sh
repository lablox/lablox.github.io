#!/bin/bash

set -e


homemd2html () {
pandoc -f markdown-auto_identifiers -t html5 --lua-filter=$maindir/builder/auto_identifiers_underscore.lua index.md -o body.html
cat index.md | head -n1 | sed -E "s|^#\s||g;s|\s$||g" > title
for ((obj = $(ls -fA1 ../markdown/p | wc -l) ; obj >= 1 ; obj--))
do
    cat ../markdown/p/$obj/index.md | head -n1 | sed -E "s|^#\s||g;s|\s$||g" > "$obj"_title
    sed "s/objnumber/$obj/g" ../builder/layer >> pancake
    sed "s/objnumber/$obj/g" ../builder/list_layer >> listcake
done
cat $maindir/builder/home_header.html body.html $maindir/builder/banner pancake $maindir/builder/footer.html | m4 > index-premini.html
html-minifier -c $maindir/builder/html-minifier.conf index-premini.html > index.html
}

listmaker () {
echo "Plain list of all articles" > title
echo "<h1>$(cat title)</h1>" | cat - listcake > listpancake
sed "s/include({{body\.html}})/include({{listpancake}})/g;s/page\.css/list.css/g" $maindir/builder/page_header.html | cat - $maindir/builder/footer.html | m4 > list-premini.html
html-minifier -c $maindir/builder/html-minifier.conf list-premini.html > ../docs/p/index.html
rm list-premini.html title listcake listpancake
}

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
cat $maindir/builder/page_header.html $maindir/builder/footer.html | m4 > $name-premini.html
html-minifier -c $maindir/builder/html-minifier.conf $name-premini.html > $name.html
rm body.html $name-premini.html title $1
}

recursivemd2html () {
for obj in $(ls -fA1)
do
    if [[ -d $obj ]]
    then
        cd $obj
        recursivemd2html
        cd ..
    elif [[ $obj = "index.md" ]]
    then
        md2html $obj
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
lintmini list.css
lintmini 404.css
rm -rf docs
cp -r markdown docs
mkdir h404
mv docs/index.md docs/404.md h404
mv home.css 404.css h404
cd h404
homemd2html
404md2html
listmaker
cd ../docs
recursivemd2html
cd $maindir
mv h404/index.html h404/404.html docs
cp ./builder/imorty.jpg docs
rm -rf h404 page.css home.css list.css
