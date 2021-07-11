#!/bin/bash
#Bash script that automatically places the relevant cuDNN library files into the conda environment of choice for TensorFlow v2.4.1, CUDA v11.2, and cuDNN v8.1

clear

printf "cuDNN library installer for JupyterHub-like environments v0.1\nby @lyh16 210711"
printf "\n\nThis operation is only valid for JupyterHub-like environments. Do you want to continue?\n"
select yn in "Yes" "No";
do
	case $yn in
		Yes ) break;;
		No ) printf "\nBye bye!\n"; exit;;
	esac
done

clear

printf "This operation only works if you have extracted the cuDNN tarfile in /opt of the host system. Is this requirement met?\n"
select yn in "Yes" "No";
do
	case $yn in
		Yes ) break;;
		No ) printf "\nPlease install the relevant NVIDIA Graphic Driver, CUDA, and cuDNN as per\n\nhttps://medium.com/analytics-vidhya/install-cuda-11-2-cudnn-8-1-0-and-python-3-9-on-rtx3090-for-deep-learning-fcf96c95f7a1\n\nand try again!\n"; exit;;
	esac
done

clear

DRVR_LOC="/opt/cuda/"
if [ -d "$DRVR_LOC" ] || [ -L "$DRVR_LOC" ]; then
	# Take action if $DRVR_LOC directory exists #
	printf "Using cuDNN library files in ${DRVR_LOC} of host system!\n\n"
	printf "Please open a conda terminal for your environment and enter the following code in Python interactive mode one line at a time.\n\nimport sys\nsys.executable\n\n"
	printf "Now please copy the path inside the quotation marks.\n\n"
	printf "Examples:\n"
	printf "Good: /home/jupyter-username/.conda/envs/tf/bin/python\n"
	printf "Bad: '/home/jupyter-username/.conda/envs/tf/bin/python'\n\n"
	read -p "Please paste the path here: " xpath
	epath=${xpath%/bin/python}
	if [ ! -e "$epath" ]; then
		echo "The given path does not exist! Please check whether the supplied path is accurate!"
		exit 2
	fi
	printf "\nCopying cudnn*.h to supplied JupyterHub environment!\n"
	sudo cp /opt/cuda/include/cudnn*.h $epath/include
	printf "Done!\n"
	printf "Copying libcudnn* to supplied JupyterHub environment!\n"
	sudo cp /opt/cuda/lib64/libcudnn* $epath/lib
	printf "Done!\n"
	printf "Resetting permissions for files!\n"
	sudo chmod a+r /usr/local/cuda/include/cudnn*.h $epath/lib/libcudnn*
	printf "Done!\n"
	sleep 3

	clear

	printf "Now, we will make sure your jupyter kernel runs the correct executable for your environment.\n\n"
	printf "Please open a conda terminal with your environment activated and enter the following code.\n\njupyter kernelspec list\n\n"
	printf "Now please copy the kernel path for the relevant environment.\n\n"
	printf "Example: /home/jupyter-username/.local/share/jupyter/kernels/sandbox\n\n"
	read -p "Please paste the path here: " kpath
	if [ ! -e "$kpath" ]; then
		printf "\n\nThe given path does not exist! Please check whether the supplied path is accurate!\n"
		exit 2
	fi
	printf "\nChecking and modifying executable path!\n"
	file=$kpath/kernel.json
	search="/opt/tljh/user/bin/python"
	sudo sed -i "s# $search# $xpath#" $file
	printf "Done!\n\n"
	printf "Congratulations! All operations have finished!\n\n"
	printf "Please completely shutdown your kernel/notebook and start it again so that the changes we made may be successfully applied!\n"

else
	# Control will jump here if $DRVR_LOC does NOT exist #
	printf "Error: ${DRVR_LOC} not found! Please extract the relevant cuDNN tarfile into /opt of the host system!\n"
	exit 1
fi
