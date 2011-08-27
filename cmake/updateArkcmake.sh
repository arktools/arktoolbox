#!/bin/bash
# script used to update cmake modules from git repo, can't make this
# a submodule otherwise it won't know how to interpret the CMakeLists.txt
if [ -d arkcmake ]; then rm -rf arkcmake; fi
git clone git://github.com/arktools/arkcmake.git arkcmake
rm -rf arkcmake/*.git
