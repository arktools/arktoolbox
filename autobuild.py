#!/usr/bin/python 
# Author: Lenna X. Peterson (github.com/lennax)
# based on bash script by James Goppert (github.com/jgoppert)

import sys # for sys.argv[] and sys.platform
import os # for chdir()
import subprocess # for check_call()

makeargs = "-j8"
cmakeargs = " "

def install_build(cmakeargs):
	if cmakeargs == " ":
		print "You chose install build"
	subprocess.check_call('mkdir -p build', shell=True)
	os.chdir("build")
	cmake_call = "cmake" + cmakeargs + ".."
	subprocess.check_call(cmake_call, shell=True)
	subprocess.check_call(["make", makeargs])
	raise SystemExit
	
def dev_build():
	print "You chose developer build"
	cmakeargs = " -DIN_SRC_BUILD::bool=TRUE "
	install_build(cmakeargs)

def grab_deps():
	print "You chose to install dependencies"
	if 'linux' in sys.platform:
		subprocess.check_call('sudo apt-get install cmake', shell=True)
	elif 'darwin' in sys.platform:
		subprocess.check_call('sudo port install cmake', shell=True)
	else: 
		print "Platform not recognized (did not match linux or darwin)"
	raise SystemExit

# requires PROFILE definition in CMakeLists.txt:
# set(CMAKE_BUILD_TYPE PROFILE)
# set(CMAKE_CXX_FLAGS_PROFILE "-g -pg")
# set(CMAKE_C_FLAGS_PROFILE "-g -pg")
def profile():
	print "You chose to compile for gprof"
	cmakeargs = " -DBUILD_TYPE=PROFILE -DIN_SRC_BUILD::bool=TRUE "
	install_build(cmakeargs)

def remake():
	print "You chose to recall make on the previously configured build"
	os.chdir("build")
	subprocess.check_call(["make", makeargs])
	raise SystemExit

def package_source():
	print "You chose to package the source"
	install_build(cmakeargs)
	subprocess.check_call(["make", "package_source"])
	raise SystemExit

def package():
	print "You chose to package the binary"
	install_build(cmakeargs)
	subprocess.check_call(["make", "package"])
	raise SystemExit

def clean():
	print "You chose to clean the build"
	subprocess.check_call('rm -rf build', shell=True)
	# menu()
	
def menu():
	print "1. developer build: used for development."
	print "2. install build: used for building before final installation to the system."
	print "3. grab dependencies: installs all the required packages for debian based systems (ubuntu maverick/ debian squeeze,lenny) or darwin with macports."
	print "4. package source: creates a source package for distribution."
	print "5. package: creates binary packages for distribution."
	print "6. remake: calls make again after project has been configured as install or in source build."
	print "7. clean: removes the build directory."
	print "8. profile: compiles for gprof."
	print "9. end."
	opt = raw_input("Please choose an option: ")
	return opt

loop_num = 0
# continues until a function raises system exit
while (1): 	
	if len(sys.argv) == 2 and loop_num == 0:
		opt = sys.argv[1]
		loop_num += 1
	else:
		opt = menu()

	opt = int(opt)
	if   opt == 1:
		dev_build()
	elif opt == 2:
		install_build(cmakeargs)
	elif opt == 3: 
		grab_deps()
	elif opt == 4:
		package_source()
	elif opt == 5:
		package()
	elif opt == 6:
		remake()
	elif opt == 7:
		clean()
	elif opt == 8:
		# requires definition in CMakeLists.txt (see def above)
		profile()
	elif opt == 9:
		raise SystemExit
	else:
		print "Invalid option. Please try again. " 