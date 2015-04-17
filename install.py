#coding=utf-8
import os
import shutil

def getFiles(mypath):
	files = []
	for (dirpath, dirnames, filenames) in os.walk(mypath):
		for f in filenames:
			files.append(f)
		break

	return files

def linkFiles(mypath, files):
	HOME = os.environ['HOME']
	oldDir = os.path.join(HOME, "old_dotfiles")
	if not os.path.exists(oldDir):
		# Create oldDir directory
		os.mkdir(oldDir)

	elif not os.path.isdir(oldDir):
		# Abort, a non-directory
		print "Non-directory %s does already exists, please rename"%(oldDir)
		return

	for f in files:
		src = os.path.join(mypath, f)
		dst = os.path.join(HOME, "."+f)

		if os.path.exists(dst) and os.path.isfile(dst):
			# Move file to oldDir
			shutil.move(dst, os.path.join(oldDir, f))

                elif os.path.exists(dst) and os.path.isdir(dst):
		    print "Directory %s does already exists, please rename"%(dst)
                    print "Skipping %s"%(dst)
                    continue

                cmd = "ln -s %s %s"%(src, dst)
                print cmd
                os.system(cmd)

if __name__ == "__main__":
	mypath = os.path.abspath("./dots/")
	files = getFiles(mypath)
	linkFiles(mypath, files)
