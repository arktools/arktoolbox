#!/bin/bash
# script used to update cmake modules from git repo, can't make this
# a submodule otherwise it won't know how to interpret the CMakeLists.txt
git clone git@github.com:jgoppert/arkCMake.git tmp
rm *.cmake
rm -rf tmp/.git
mv tmp/* .
rm -rf tmp
