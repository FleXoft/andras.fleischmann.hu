#!/bin/sh

PhotoSwipeGenerator.pl -verb
jekyll b
cp _site/ii.html index.html
