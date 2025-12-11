### 命令脚本
#### 启动带Nvidia显卡的Docker: 
	sudo docker run --restart unless-stopped -dP --gpus all --network host --shm-size=4096m --privileged -it --device=/dev/gdrdrv:/dev/gdrdrv -v /lib/modules:/lib/modules -v /dev/hugepages:/dev/hugepages -v ~/share:/opt/cuBB/share --userns=host --ipc=host -v /var/log/aerial:/var/log/aerial --name cuBB1 nvcr.io/nvidia/aerial/aerial-cuda-accelerated-ran:25-1-cubb

#### Backup git changes
	git archive --output=xxx.zip $(git diff --name-only comit-hash1 comit-hash2 --diff-filter=ACMRTUXB)
	git archive -o update.zip HEAD $(git diff master srsreqopt --name-only)
	git archive --output=update.zip HEAD $(git diff --name-only brach_old branch_new --diff-filter=ACMRTUXB)
	git archive -o update.zip HEAD $(git diff --name-only)

#### gdb查看结构:
	gdb build/l2_ps/build/libl2ps.so --command=gdb_check_structs

