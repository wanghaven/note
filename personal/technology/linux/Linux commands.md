- 打包： tar -cf soft.tar soft 
	Tar:   tar-cvf /home/vivek/projects.tar/home/vivek/projects
- 解包： tar -xf soft.tar soft 
- 打包压缩： tar czvf usr.tar.gz dir1 dir2 
- 解压： tar -xzf usr.tar.gz 
- 压缩文件： zip good.zip good1 good2 
- 解压： unzip good.zip 
- 查找:
	查找删除 .svn文件：  find ./ -name "*.svn" -print -exec rm -fr {} \;
	查找.sh文件:  find.-iname "*.sh"-execls-l {}+
	查找并打包: find . -name "*Srs*.o" -exec tar -rvf srs.tar {} \;