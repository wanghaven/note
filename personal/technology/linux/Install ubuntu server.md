## 1 Install openssh server
安装ssh: apt-get install openssh-server
备份sshd配置文件:  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
修改内容：
Port 23 # 端口改为23，22端口已被占用ListenAddress 0.0.0.0 # 取消注释#StrictModes yes # 注释PasswordAuthentication yes # 允许密码登录
启动ssh: service ssh start
如果提示sshd error: could not load host key，则用下面的命令重新生成
	sudo rm /etc/ssh/ssh*key

## 2 Install python and change default python 
	sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1
	sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
	sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 3
	sudo update-alternatives --config python	
	sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1
	sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
	sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 2

## 3 Change to use china source list
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sudo apt-get update -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080"
	sudo apt-get upgrade -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080"

## 4 Add http proxy for apt if necessary
	apt-get -o Acquire::http::proxy="http://10.144.1.10:8080/"  install xxxx
		-o Acquire::http::proxy="http://defraprx-fihelprx.glb.nsn-net.net:8080"
		-o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080"
	    -o Acquire::http::proxy="http://cnbeiaj-proxy001.china.nsn-net.net:8080"

## 5 [Installing GCC on Ubuntu](https://linuxize.com/post/how-to-install-gcc-compiler-on-ubuntu-18-04/)
	cnhanab-proxy001.china.nsn-net.net
	sudo apt install build-essential -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080/"
	sudo apt-get install manpages-dev -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080/"
	sudo apt-get install zlib1g-dev  -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080/"
	or sudo apt-get install zlib* -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080/"
	sudo apt-get install cmake  -o Acquire::http::proxy="http://cnhanab-proxy001.china.nsn-net.net:8080/"

### 5.1 ARM64 gcc
	sudo apt-get install gcc-aarch64-linux-gnu -o Acquire::http::proxy="http://10.144.1.10:8080/"
	sudo apt-get install g++-aarch64-linux-gnu -o Acquire::http::proxy="http://10.144.1.10:8080/"
	sudo apt-get install gcc-aarch64-linux-gnu -o Acquire::http::proxy="http://127.0.0.1:10809/"
	sudo apt-get install g++-aarch64-linux-gnu -o Acquire::http::proxy="http://127.0.0.1:10809/"

### 5.2 ARM32
	apt-get update  
	apt-get install binutils-multiarch
	dpkg --add-architecture armhf
	
	##Manually add correct armhf repositories to /etc/apt/sources.list  
	apt-get update  
	apt-get install libudev-dev:armhf
	sudo dpkg --remove-architecture armhf
	From <[https://askubuntu.com/questions/705895/how-to-fix-a-failed-to-fetch-binary-armhf-packages-error-during-apt-get-update](https://askubuntu.com/questions/705895/how-to-fix-a-failed-to-fetch-binary-armhf-packages-error-during-apt-get-update)>
	From <[https://askubuntu.com/questions/1061979/cross-compile-for-armhf-and-install-a-static-library](https://askubuntu.com/questions/1061979/cross-compile-for-armhf-and-install-a-static-library)>

## 6 Set/unset http proxy
	export http_proxy=http://10.144.1.10:8080 
	export https_proxy=http://10.144.1.10:8080
	export HTTP_PROXY=http://10.144.1.10:8080
	export HTTPS_PROXY=http://10.144.1.10:8080
	
	unset http_proxy
	unset https_proxy
	unset HTTP_PROXY
	unset HTTPS_PROXY
	
	##git proxy
	git config --global http.proxy [http://10.144.1.10:8080](http://10.144.1.10:8080)
	git config --global https.proxy [http://10.144.1.10:8080](http://10.144.1.10:8080)
	git config --global --unset http.proxy
	git config --global --unset https.proxy
	export http_proxy=http://cnhanab-proxy001.china.nsn-net.net:8080

### 6.1 Installing Bazel on Ubuntu
#### 6.1.1 Step 1: Install required packages
	First,installtheprerequisites:pkg-config,zip,g++,zlib1g-dev,unzip,andpython3.
	sudo apt-get install pkg-config zip g++ zlib1g-dev unzip python3

#### 6.1.2 Step 2: Download Bazel
	Next,downloadtheBazelbinaryinstallernamedbazel-<version>-installer-linux-x86_64.shfromtheBazelreleasespageonGitHub.

#### 6.1.3 Step 3: Run the installer
	Run the Bazel installer as follows:
		chmod +x bazel-<version>-installer-linux-x86_64.sh
			./bazel-<version>-installer-linux-x86_64.sh --user
	The --user flag installs Bazel to the $HOME/bin directory on your system and sets the .bazelrc path to $HOME/.bazelrc. Use the --help command to see additional installation options.

#### 6.1.4 Step 4: Set up your environment
	If you ran the Bazel installer with the --user flag as above, the Bazel executable is installed in your $HOME/bin directory. It’s a good idea to add this directory to your default paths, as follows:
	export PATH="$PATH:$HOME/bin"
		You can also add this command to your ~/.bashrc file.

## 7 [[Install TensorFlow with pip]]

## 8 Install pytorch
	pip3installtorch==1.3.0+cputorchvision==0.4.1+cpu-fhttps://download.pytorch.org/whl/torch_stable.html

## 9 Build and install glow
	[https://github.com/pytorch/glow](https://github.com/pytorch/glow)
	cmake -G Ninja ../glow -DCMAKE_BUILD_TYPE=Debug -DLLVM_DIR=/usr/lib/llvm-8/lib/cmake/llvm
	ninja all
	-DGLOW_BUILD_PYTORCH_INTEGRATION=ON -DPYTORCH_DIR=/home/ptr476/.local/lib/python3.7/site-packages/torch -DTORCH_GLOW=/mnt/c/work/code/ai/pytorch/glow/torch_glow
	
	If missing GLOG_LIBRARY; PROTOBUF_LIBRARY, add -D:
	-DGLOG_LIBRARY=/usr/lib/x86_64-linux-gnu/libglog.a  -DProtobuf_LIBRARY=/usr/lib/x86_64-linux-gnu/libprotobuf.a
	
	wget [https://xxxx](https://xxxx)  -e use_proxy=yes -e https_proxy=127.0.0.1:10809
	wget [https://xxxx](https://xxxx) -e use_proxy=yes -e http_proxy=http://defraprx-fihelprx.glb.nsn-net.net:8080 -e https_proxy=http://defraprx-fihelprx.glb.nsn-net.net:8080