进行sd卡烧录:
----------------------------------------------
1.解压fuse.zip

2.把image.tar.gz解压，install目录和arago-glsdk-multimedia-image-dra7xx-evm.tar.gz拷贝到
fuse/image/ 目录

3.在fuse目录运行：
sudo ./mksdboot.sh --device /dev/sdx

-----------------------------------------------
在console通过命令启动(需等weston启动完成)
sh-3.2#ftest

