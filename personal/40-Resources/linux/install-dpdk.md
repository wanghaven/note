## 1 Enabling root account:
	sudo passwd -u root
	sudo passwd root

## 2 intall dpdk
	sudo apt-get install dpdk-dev libdpdk-dev
	sudo apt-get install build-dep dpdk
	sudo apt-get install dpdk-doc dpdk-dev libdpdk-dev
	
	##Example With proxy: 
	sudo apt-get -o Acquire::http::proxy="http://10.144.1.10:8080/" install dpdk-dev libdpdk-dev
	sudo apt-get -o Acquire::http::proxy="http://10.144.1.10:8080/"  install build-dep dpdk

## 3 set enviroment
	. /usr/share/dpdk/dpdk-sdk-env.sh
	##build an example of l2fwd
	make -C /usr/share/dpdk/examples/l2fwd

## 4 build DPDK to install
	# get dev libs and examples  
	$ apt-get install dpdk-doc dpdk-dev libdpdk-dev  
	# auto-get build dependencies (here you'll need the deb-src again)  
	$ apt-get build-dep dpdk  
	# get build env config  
	. /usr/share/dpdk/dpdk-sdk-env.sh  
	# build example  
	mkdir -p /tmp/l2fwd  
	make -C /usr/share/dpdk/examples/l2fwd "O=/tmp/l2fwd"