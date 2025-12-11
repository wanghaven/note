[Emulating ARM on Debian Ubuntu](https://gist.github.com/bruce30262/e0f12eddea638efe7332#file-armdebianubuntu-md)

You might want to read [this](http://www.memetic.org/raspbian-benchmarking-armel-vs-armhf/) to get an introduction to armel vs armhf.

If the below is too much, you can try [Ubuntu-ARMv7-Qemu](https://wiki.ubuntu.com/Kernel/Dev/QemuARMVexpress) but note it contains non-free blobs.


### 0.1 Running ARM programs under linux (without starting QEMU VM!)

First, cross-compile user programs with GCC-ARM toolchain. Then install ``qemu-arm-static`` so that you can run ARM executables directly on linux

**If there's no `qemu-arm-static` in the package list, install `qemu-user-static` instead**


```
# armel packages also exist
sudo apt-get install gcc-arm-linux-gnueabihf libc6-dev-armhf-cross qemu-arm-static
```

Then compile your programs in amd64 directly:
```
cat > hello.c << EOF

#include <stdio.h>
int main(void) { return printf("Hello ARM!\n"); }
EOF

arm-linux-gnueabihf-gcc -static  -ohello hello.c

file hello
hello: ELF 32-bit LSB executable, ARM, version 1 (SYSV), statically linked,

./hello
Hello ARM!
```

If you want a dynamically-linked executable, you've to pass the linker path too:  
```
arm-linux-gnueabihf-gcc -ohello hello.c
qemu-arm -L /usr/arm-linux-gnueabihf/ ./hello   # or qemu-arm-static if you install qemu-user-static
```

If you want to run an ARM64 binary:
```
sudo apt-get install libc6-dev-arm64-cross gcc-aarch64-linux-gnu 
qemu-aarch64 -L /usr/aarch64-linux-gnu/ [path-to-binary] # or qemu-aarch64-static if you install qemu-user-static
```

For running the C++ program:
* ARM
```
sudo apt-get install g++-arm-linux-gnueabihf libstdc++-4.8-dev-armhf-cross
```
* AArch64
```
sudo apt-get install g++-aarch64-linux-gnu libstdc++-4.8-dev-arm64-cross
```  
**Notice that the version number of the libcstdc++ might change**

[Debugging using GDB](http://ubuntuforums.org/showthread.php?t=2010979&s=096fb05dbd59acbfc8542b71f4b590db&p=12061325#post12061325)

### 0.2 Install QEMU
```
sudo apt-get install qemu
```

### 0.3 Create a hard disk
Create a hard disk for your virtual machine with required capacity.
```
qemu-img create -f raw armdisk.img 8G
```

You can then install Debian using an ISO CD or directly from vmlinuz

### 0.4 Netboot from vmlinuz

First, you should decide what CPU and machine type you want to emulate.

You can get a list of all supported CPUs (to be passed with `-cpu` option, see later below):
```
qemu-system-arm -cpu help
```

You can get a list of all supported machines (to be passed with `-M` option, see later below):
```
qemu-system-arm -machine help
```

In this example, I chose the `cortex-a9` CPU and `vexpress-a9` machine. This is an ARMv7 CPU which Debian calls as `armhf` (ARM hard float). You must download vmlinuz and initrd files for, say [Wheezy armhf netboot](http://ftp.debian.org/debian/dists/wheezy/main/installer-armhf/current/images/vexpress/netboot/). Cortex-A8, A9, A15 are all ARMv7 CPUs. 


You can emulate ARMv6 which Debian calls as `armel` by downloading the corresponding files for [Wheezy armel netboot](http://ftp.debian.org/debian/dists/wheezy/main/installer-armel/current/images/versatile/netboot/).
Note that you need `armel` for ARMv5, v6. Raspberry Pi uses ARMv6. In this case, the cpu is `arm1176` and machine is `versatilepb`.


Create a virtual machine with 1024 MB RAM and a Cortex-A9 CPU. Note that we must `-sd` instead of `-sda` because vexpress kernel doesn't support PCI SCSI hard disks. You'll install Debian on on MMC/SD card, that's all it means.

```
qemu-system-arm -m 1024M -sd armdisk.img \
                -M vexpress-a9 -cpu cortex-a9 \
                -kernel vmlinuz-3.2.0-4-vexpress -initrd initrd.gz \
                -append "root=/dev/ram"  -no-reboot
```

Specifying `-cpu` is optional. It defaults to `-cpu=any`. However, `-M` is mandatory.

This will start a new QEMU window and the Debian installer will kick-in. Just proceed with the installation (takes maybe 3 hours or so). Make sure you install "ssh-server" in tasksel screen.


NOTE: For creating ARMv6, just pass `versatilepb`:

```
qemu-system-arm -m 1024M -M versatilepb \
                -kernel vmlinuz-3.2.0-4-versatile -initrd initrd.gz \
                -append "root=/dev/ram" -hda armdisk.img -no-reboot
```
 

### 0.5 Netboot from ISO


Download netboot ISO for [armhf](http://cdimage.debian.org/debian-cd/7.2.0/armhf/iso-cd/) or [armel](http://cdimage.debian.org/debian-cd/7.2.0/armel/iso-cd/) as needed. 


WAIT! Apparently, these Debian CD images are not bootable! But Ubuntu's ARM CD image works [2].


### 0.6 First boot from newly installed system

You need to copy vmlinuz from the installed disk image and pass it again to qemu-system-img [Qemu wiki]
(http://en.wikibooks.org/wiki/QEMU/Images#Mounting_an_image_on_the_host").

#### 0.6.1 For armel

```
sudo modprobe nbd max_part=16
sudo qemu-nbd -c /dev/nbd0 armel.img
mkdir ~/qemu-mounted
sudo mount /dev/nbd0p1 ~/qemu-mounted
mkdir after-copy

cp ~/qemu-mounted/boot/* after-copy/

sudo umount ~/qemu-mounted
sudo qemu-nbd -d /dev/nbd0
sudo killall qemu-nbd
```

Then pass the copied kernel and initrd to qemu-system-img. Also note that we are now booting from `/dev/sda1` because that is where Linux was installed

```
qemu-system-arm -M versatilepb -m 1024M  \
                -kernel after-copy/vmlinuz-3.2.0-4-versatile \
                -initrd after-copy/initrd.img-3.2.0-4-versatile \
                -hda armel.img -append "root=/dev/sda1" 
```

And there you go, play with ARM to your heart's extent!

#### 0.6.2 For armhf

Extract & copy the boot files exactly as before (but for armhf.img) and pass while invoking:

```
qemu-system-arm -m 1024M -M vexpress-a9  \
                -kernel armhf-extracted/vmlinuz-3.2.0-4-vexpress \
                -initrd armhf-extracted/initrd.img-3.2.0-4-vexpress \
                -append "root=/dev/mmcblk0p1" -sd armhf.img

```

Once again, note the device (`mmcblk0p1`) and partition (`armhf.img`) reflect SD-card usage.


#### 0.6.3 Connecting to the SSH server

Login to the guest OS and create a private/public key pair: `ssh-keygen -t rsa`.

On the host, just redirect some random port from the host to guest's port 22 (or whichever port the SSH server is running on, see /etc/ssh/sshd_config)

```
qemu-system-arm ....  -redir tcp:5555::22 &
```

Then you can connect to SSH just like `ssh -p 5555 localhost`.

#### 0.6.4 Chroot Voodoo your ARM VM (architectural chroot with QEMU)

After the install of your ARM, you will probably see that it is really slow.
To speed up your arm, you can chroot it natively and let `qemu-user-static` interpret the ARM instruction. [5]
```
sudo apt-get install qemu-user-static kpartx
```

We mount the image using loopback
```
sudo kpartx -a -v armdisk.img
sudo mkdir /mnt/arm-vm
sudo mount /dev/mapper/loop0p2 /mnt/arm-vm
```

Copy the static binary 
```
sudo cp /usr/bin/qemu-arm-static /mnt/arm-vm/usr/bin
sudo mount -o bind /proc /mnt/arm-vm/proc
sudo mount -o bind /dev /mnt/temp/dev
sudo mount -o bind /sys /mnt/temp/sys
```

We register `qemu-arm-static` as ARM interpreter to the kernel linux. [6]
```
#This can only be run as root (sudo don't work)
sudo su
echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > /proc/sys/fs/binfmt_misc/register
exit
```

Now we chroot to our VM.
```
sudo chroot /mnt/arm-vm
```

Let see if it work:
```
$ uname -a
Linux cis-linux-arm 2.6.32 #19-Ubuntu SMP Wed Oct 9 16:20:46 UTC 2013 armv7l GNU/Linux
```

N.B: After test, qemu 1.1 (Debian wheezy) had some strange behaviour but the 1.5 (Ubuntu saucy) was working perfectly !

When you finished your work you should unmount everything to avert bad behaviour.
Do not forget to not start your VM with Qemu before unmount everything !
```
sudo umount /mnt/arm-vm/proc
sudo umount /mnt/arm-vm/dev
sudo umount /mnt/arm-vm/sys
sudo umount /mnt/arm-vm
sudo kpartx -d -v armdisk.img
```

##### 0.6.4.1 References

[1] http://www.linuxforu.com/2011/05/quick-quide-to-qemu-setup/
[2] http://blog.troyastle.com/2010/07/building-arm-powered-debian-vm-with.html
[3] [Differences between ARM926, ARM1136, A8 and A9](http://processors.wiki.ti.com/index.php/Feature_Comparison:_ARM_926,_1136_and_Cortex-A8)
[4] http://www.makestuff.eu/wordpress/running-debian-for-arm-powerpc-on-qemu/
[5] http://www.darrinhodges.com/chroot-voodoo/
[6] https://en.wikipedia.org/wiki/Binfmt_misc