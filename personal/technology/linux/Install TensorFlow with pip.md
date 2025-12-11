## 1 Install the Python development environment on your system
Python 3 Python 2.7
Check if your Python environment is already configured:
Requires Python > 3.4 and pip >= 19.0
python3 --version
pip3 --version
virtualenv --version
From <[https://www.tensorflow.org/install/pip](https://www.tensorflow.org/install/pip)>

If these packages are already installed, skip to the next step.
Otherwise, install [Python](https://www.python.org/), the [pip package manager](https://pip.pypa.io/en/stable/installing/), and [Virtualenv](https://virtualenv.pypa.io/en/stable/):
[Ubuntu](https://www.tensorflow.org/install/pip#ubuntu)[mac OS](https://www.tensorflow.org/install/pip#mac-os)[Windows](https://www.tensorflow.org/install/pip#windows)[Raspberry Pi](https://www.tensorflow.org/install/pip#raspberry-pi)[Other](https://www.tensorflow.org/install/pip#other)

sudo apt update
sudo apt install python3-dev python3-pip
sudo pip3 install -U virtualenv  # system-wide install
pip3 install -U virtualenv --proxy=defraprx-fihelprx.glb.nsn-net.net:8080
defraprx-fihelprx.glb.nsn-net.net:8080
cnproxy.int.nokia-sbell.com:8080
From <[https://www.tensorflow.org/install/pip](https://www.tensorflow.org/install/pip)>

## 2 Create a virtual environment (recommended)
Python virtual environments are used to isolate package installation from the system.
[Ubuntu / mac OS](https://www.tensorflow.org/install/pip#ubuntu--mac-os)[Windows](https://www.tensorflow.org/install/pip#windows)[Conda](https://www.tensorflow.org/install/pip#conda)
Create a new virtual environment by choosing a Python interpreter and making a ./venv directory to hold it:
virtualenv --system-site-packages -p python3.7 ./venv/tf1.15
Activate the virtual environment using a shell-specific command:
source ./venv/bin/activate  # sh, bash, ksh, or zsh
When virtualenv is active, your shell prompt is prefixed with (venv).
Install packages within a virtual environment without affecting the host system setup. Start by upgrading pip:
pip install --upgrade pip --proxy=10.144.1.10:8080
pip list  # show packages installed within the virtual environment
And to exit virtualenv later:
deactivate  # don't exit until you're done using TensorFlow

## 3 Install the TensorFlow pip package
Choose one of the following TensorFlow packages to install [from PyPI](https://pypi.org/project/tensorflow/):
- tensorflow —Latest stable release for CPU-only (recommended for beginners)
- tensorflow-gpu —Latest stable release with [GPU support](https://www.tensorflow.org/install/gpu)(Ubuntu and Windows)
- tf-nightly —Preview nightly build for CPU-only (unstable)
- tf-nightly-gpu —Preview nightly build with [GPU support](https://www.tensorflow.org/install/gpu)(unstable, Ubuntu and Windows)
- tensorflow==2.0.0-rc0 —Preview TF 2.0 RC build for CPU-only (unstable)
- tensorflow-gpu==2.0.0-rc0 —Preview TF 2.0 RC build with [GPU support](https://www.tensorflow.org/install/gpu) (unstable, Ubuntu and Windows)
Package dependencies are automatically installed. These are listed in the[setup.py](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/pip_package/setup.py) file under REQUIRED_PACKAGES.
[Virtualenv install](https://www.tensorflow.org/install/pip#virtualenv-install)[System install](https://www.tensorflow.org/install/pip#system-install)
pip install tensorflow==1.15.0 --proxy=defraprx-fihelprx.glb.nsn-net.net:8080

From <[https://pypi.org/project/tensorflow/1.15.0/](https://pypi.org/project/tensorflow/1.15.0/)>

## 4 Verify the install:
python -c "import tensorflow as tf;print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
Success: TensorFlow is now installed. Read the [tutorials](https://www.tensorflow.org/tutorials) to get started.
Package location
A few installation mechanisms require the URL of the TensorFlow Python package. The value you specify depends on your Python version.

|Version|URL|
| --- | --- |
|Python 2.7 CPU-only|[https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp27-none-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp27-none-linux_x86_64.whl)|
|Python 2.7 GPU support|[https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp27-none-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp27-none-linux_x86_64.whl)|
|Python 3.4 CPU-only|[https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp34-cp34m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp34-cp34m-linux_x86_64.whl)|
|Python 3.4 GPU support|[https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp34-cp34m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp34-cp34m-linux_x86_64.whl)|
|Python 3.5 CPU-only|[https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp35-cp35m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp35-cp35m-linux_x86_64.whl)|
|Python 3.5 GPU support|[https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp35-cp35m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp35-cp35m-linux_x86_64.whl)|
|Python 3.6 CPU-only|[https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp36-cp36m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp36-cp36m-linux_x86_64.whl)|
|Python 3.6 GPU support|[https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp36-cp36m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp36-cp36m-linux_x86_64.whl)|
|Python 3.7 CPU-only|[https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp37-cp37m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.14.0-cp37-cp37m-linux_x86_64.whl)|
|Python 3.7 GPU support|[https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp37-cp37m-linux_x86_64.whl](https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.14.0-cp37-cp37m-linux_x86_64.whl)|
|macOS (CPU-only)||
|Python 2.7|[https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.14.0-py2-none-any.whl](https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.14.0-py2-none-any.whl)|
|Python > 3.4|[https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.14.0-py3-none-any.whl](https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.14.0-py3-none-any.whl)|
|Windows||
|Python 3.5 CPU-only|[https://storage.googleapis.com/tensorflow/windows/cpu/tensorflow-1.14.0-cp35-cp35m-win_amd64.whl](https://storage.googleapis.com/tensorflow/windows/cpu/tensorflow-1.14.0-cp35-cp35m-win_amd64.whl)|
|Python 3.5 GPU support|[https://storage.googleapis.com/tensorflow/windows/gpu/tensorflow_gpu-1.14.0-cp35-cp35m-win_amd64.whl](https://storage.googleapis.com/tensorflow/windows/gpu/tensorflow_gpu-1.14.0-cp35-cp35m-win_amd64.whl)|
|Python 3.6 CPU-only|[https://storage.googleapis.com/tensorflow/windows/cpu/tensorflow-1.14.0-cp36-cp36m-win_amd64.whl](https://storage.googleapis.com/tensorflow/windows/cpu/tensorflow-1.14.0-cp36-cp36m-win_amd64.whl)|
|Python 3.6 GPU support|[https://storage.googleapis.com/tensorflow/windows/gpu/tensorflow_gpu-1.14.0-cp36-cp36m-win_amd64.whl](https://storage.googleapis.com/tensorflow/windows/gpu/tensorflow_gpu-1.14.0-cp36-cp36m-win_amd64.whl)|
|Raspberry PI (CPU-only)||
|Python 2.7, Pi0 or Pi1|[https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp27-none-linux_armv6l.whl](https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp27-none-linux_armv6l.whl)|
|Python 2.7, Pi2 or Pi3|[https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp27-none-linux_armv7l.whl](https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp27-none-linux_armv7l.whl)|
|Python 3, Pi0 or Pi1|[https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp34-none-linux_armv6l.whl](https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp34-none-linux_armv6l.whl)|
|Python 3, Pi2 or Pi3|[https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp34-none-linux_armv7l.whl](https://storage.googleapis.com/tensorflow/raspberrypi/tensorflow-1.14.0-cp34-none-linux_armv7l.whl)|
From <[https://www.tensorflow.org/install/pip](https://www.tensorflow.org/install/pip)>