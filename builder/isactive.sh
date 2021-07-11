#!/bin/bash

set -e

topdir=$(echo $1 | cut -d'/' -f7- | cut -d'/' -f1)
test -z $topdir && ln=1
[[ $topdir = gnr ]] && ln=2
[[ $topdir = hrt ]] && ln=3
[[ $topdir = bld ]] && ln=4
[[ $topdir = lng ]] && ln=5
[[ $topdir = dgs ]] && ln=6
[[ $topdir = kdn ]] && ln=7
[[ $topdir = lvr ]] && ln=8
[[ $topdir = cnt ]] && ln=9
sed "$ln"'s|hre|class\=\"active\"\ hre|' /home/runner/work/lablox.github.io/lablox.github.io/builder/navbar
