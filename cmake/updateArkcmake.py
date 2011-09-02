#!/usr/bin/python
# Author: Lenna X. Peterson (github.com/lennax)
# Based on bash script by James Goppert (github.com/jgoppert)
#
# script used to update cmake modules from git repo, can't make this
# a submodule otherwise it won't know how to interpret the CMakeLists.txt
# # # # # # subprocess# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import os # for os.path
import subprocess # for check_call()

clone_path = os.path.dirname(os.path.abspath(__file__))
os.chdir(clone_path)
if os.path.isdir('arkcmake'):
	subprocess.check_call(["rm", "-rf", "arkcmake"])
subprocess.check_call(["git", "clone", "git://github.com/arktools/arkcmake.git"])
subprocess.check_call(["rm", "-rf", "arkcmake/.git"])