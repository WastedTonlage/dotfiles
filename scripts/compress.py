import argparse
import sys
import os
import zipfile
import re
import zipfile
import shutil
import time 
import re

parser = argparse.ArgumentParser(description="Zips project files in dropbox")

parser.add_argument("folder", help="the folder to look for projects in")
parser.add_argument("-D", dest="delete", action="store_true", help="Delete zipped folders after zipping, should be completely safe, since archives are always checked")
parser.add_argument("--exclude",dest="exclude", action="store_true", help="Include all project by default")
args = parser.parse_args()

numRe = re.compile("^OA\\d{4,}")
exclude = args.exclude

excludes = []
includes = ["OA4290"]

def verifyZip(zipfileName, path):
	if (not os.path.exists(zipfileName)):
		print("couldnt find ZIP file")
		return False
	loaded = zipfile.ZipFile(zipfileName)
	if (loaded.testzip()):
		print("not a valid ZIP file")
		return False
	zippedFiles = loaded.namelist()
	realFiles = []
	for root, _, files in os.walk(path):
		for file in files:
			realFiles.append(os.path.join(root, file))
	for file in realFiles:
		file = file[len(path) + 1:].replace("\\", "/")
		if file not in zippedFiles:
			print("missing file:" + file)
			return False
	return True

def testForFolder(root, dirs, folder):
	#print("testing for " + folder)
	found = False
	for i in range(0, 25):
		i = str(i) + "_"
		if (len(i) == 2):
			i = "0" + i
		if (i + folder in dirs):
			found = True
			folder = i + folder

	if (found and len(os.listdir(os.path.join(root, folder))) > 1):
		dirs.remove(folder)
		path = os.path.join(root, folder)
		#print("Making archive of: " + path)
		make_new_archive(path)
		if (verifyZip(path + ".zip", path)):
			print("verify succeeded, deleting " + path)
			if (args.delete):
				shutil.rmtree(path)


def make_new_archive(name):
	if (os.path.exists(name + ".zip")):
		i = 0
		while os.path.exists(name + "_" + str(i) + ".zip"):
			i += 1
		make_archive(name + "_" + str(i), "zip", name)
	else:
		make_archive(name, "zip", name)

def dirSize(path):
	size = 0
	files = 0
	for root, _, DirFiles in os.walk(path):
		for file in DirFiles:
			size += os.path.getsize(os.path.join(root, file))
			files += 1
	return size, files

for project in os.listdir(sys.argv[1]):
	print("Now running project: " + project)
	projectNum = re.match(numRe, project).group(0)
	if ( (exclude and projectNum in excludes) or (not exclude and not projectNum in includes)):
		print("project is excluded")
		continue
	prevSize, prevFiles = dirSize(os.path.join( sys.argv[1], project))
	prevTime = time.time()
	for root, dirs, files in os.walk(os.path.join( sys.argv[1], project)):
		if (root == os.path.join(sys.argv[1], project)):
			testForFolder(root, dirs, "SolidWorks files")
			testForFolder(root, dirs, "Sales Layout")
			testForFolder(root, dirs, "Salgs Layout") # Is sometimes spelled in danish
			testForFolder(root, dirs, "Mechanical production")
		for file in files:
			if file.endswith(".apj"):
				#print("Found ABJ, compressing " + root)
				files = []
				dirs = []
				#zip current dir
				make_new_archive(root)
				if (verifyZip(root + ".zip", root)):
					print("verify succeeded, deleting " + root)
					if (args.delete):
						shutil.rmtree(root)
	lastSize, lastFiles = dirSize(os.path.join( sys.argv[1], project))
	print("Zipped project. Reduced dir by " + str((prevSize - lastSize) // 1024) + " KB and " + str(prevFiles - lastFiles) + " files in " + str(time.time() - prevTime) + "s")