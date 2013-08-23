#!/bin/sh

cd ../drystal
./runner.py clean
./runner.py LD27 repack
cd LD27

git checkout gh-pages
cp ../drystal/build-web/*compress* .
cp ../drystal/build-web/index.html .
du -sh *
git commit index.html *compress* -m "update pages"
git push origin gh-pages
git checkout master
