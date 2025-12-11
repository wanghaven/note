
[Linux查看端口占用 netstat netstat端口占用 linux端口 进程端口](https://blog.csdn.net/lmb1612977696/article/details/99956151)
### 1 首先查看程序的进程号
	例如程序名称为aaa，查询其运行进程号如下：
		minbo@mb ~> ps -aux | grep aaa
		minbo    16273  0.3  1.1 21475099312 92752 pts/2 Sl+ 10:18   0:01 ./aaa 
		1
		2
		则进程号就是16273。

### 2 查看进程所占端口号
	上面我们查到程序的进程号是16273，查询其占用端口号如下：
	minbo@mb ~> sudo netstat -ap | grep "16273"     // windows用findstr代替grep
	[sudo] minbo 的密码：
	tcp        0      0 mb:60272                10.80.23.122:26575     ESTABLISHED 16273/./aaa
	1
	2
	3
	可以看到该运行程序有一个TCP连接，客户端端口是60272，服务端ip是10.80.23.122，端口是26575
