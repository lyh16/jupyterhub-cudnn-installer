# jupyterhub-cudnn-installer
Instructions and a bash script on how to get TensorFlow v2.4.1 and PyTorch up and running on a JupyterHub installed on a Linux system.

An NVIDIA RTX 3090 was used as the GPU, [tljh](https://tljh.jupyter.org/en/latest/) A.K.A "The Littlest JupyterHub" as the JupyterHub, and Ubuntu 20.04 LTS as the operating system for this manual.

The provided bash script is tljh specific.
But a quick read through the code will give you the idea for different environments.

Some of the instructions or statements provided in this manual/bash script are merely based on multiple reports of success using the given environment with some personal experience supporting them, and is NOT a guarantee. Please proceed with caution concerning actons that are not recommended in the offical documents, AT YOUR OWN RISK.
Please DO NOT RUN ANYTHING that you do not understand. The provided instructions and bash script are intended to work with the stated configurations only and may mess up your setup if erroneously applied.

## Instructions
### 1. Manually install the below on host system:
	*NVIDIA Graphic Driver v460.84
	*CUDA v11.2
	*cuDNN v8.1
as per instructions on https://medium.com/analytics-vidhya/install-cuda-11-2-cudnn-8-1-0-and-python-3-9-on-rtx3090-for-deep-learning-fcf96c95f7a1

The cuDNN libraries were installed in "/opt" for this manual(i.e. /opt/cuda).

If "apt" fails to resolve issues. Use "aptitude" to install the mentioned packages.
If issues arise due to redundant driver files from the previous installation of CUDA, remove such files as per https://evols-atirev.tistory.com/43

### 2. PyTorch

Install PyTorch v1.8.1 LTS in the conda virtual environment of choice as per instructions on official website.
You may use a different supported version of PyTorch if you would like to. But do check for compatability.

```bash
conda install pytorch torchvision torchaudio cudatoolkit=11.1 -c pytorch-lts -c nvidia
```

As a rule of thumb, it is possible to disregard the CUDA v11.1 requirement in favor of CUDA v11.2.

### 3. TensorFlow

Install TensorFlow v2.4.1 in the conda environment(Python v3.8) of choice by:

```bash
python -m pip install tensorflow-gpu==2.4.1
```

Python v3.8 was chosen because it is the latest version of Python that is supported by TensorFlow v2.4.1.
For some reason, I wasn't able to get TensorFlow v2.5.0 to run properly and detect my GPU on my JupyterHub.
So, I opted for the combination of TensorFlow v2.4.1 + Python v3.8.
After the above, if any missing packages error shows, manually install each using the following template:

```bash
python -m pip install {package_name}
```

These missing packages are usually pytz, pandas, matplotlib, and pillow. These may be installed via:

```bash
python -m pip install pytz pandas matplotlib pillow
```

At times, using just "pip install" in the conda terminal installs the indicated packages in the wrong site-packages location(example: in the environment for Python v3.7 instead of Python v3.8)

The below instructions may be skipped if you can run the custom written bash script "jupyterhub_cudnn_install.sh" with sudo or root privileges(Recommended for ease of application).

Open a conda terminal.
Activate the environment you installed TensorFlow in.
Enter Python interactive mode(i.e. python + [Enter])
Run the following commands one line at a time:

```python
import sys
sys.executable
```

The above will print the path of your conda executable.

```
Example: /home/jupyter-username/.conda/envs/tf/bin/python
Template: /home/jupyter-username/.conda/envs/{environment_name}/bin/python
```

Take note of the path just up to where your {environment_name} ends; the path before "/bin/python".
Run the following commands in the host terminal:

```bash
sudo cp /opt/cuda/include/cudnn*.h /home/jupyter-username/.conda/envs/tf/include
sudo cp /opt/cuda/lib64/libcudnn* /home/jupyter-username/.conda/envs/tf/lib
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /home/jupyter-username/.conda/envs/tf/lib/libcudnn*
```

The above will insert the "missing" required library files into your chosen environment.

DONE!!!
Now you can run both PyTorch and TensorFlow at great speed with your RTX 3090!

### Addendum:

If any packages appear missing notwithstanding the above instructions,
open a conda terminal and run the following:

```bash
jupyter kernelspec list
```

Take note of the path of your environment of concern.
Use the host system's terminal and "cd" to the respective environment path.
Then run the following:

```bash
sudo nano kernel.json
```

Replace the erroneous Python executable path with the one presented by (Python interactive mode)"sys.executable" in the conda terminal.
Save the changes. Then completely shutdown your kernel/notebook, and start it again;so the changes we made may be successfully applied.

---   FIN   ---
