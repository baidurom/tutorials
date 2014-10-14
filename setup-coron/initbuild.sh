#!/bin/bash
echo -e "\e[46;37;1m"
clear
username=`whoami`
thisDir=`pwd`


addRulesFunc(){
	read mIdVendor mIdProduct
	echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\""$mIdVendor"\", ATTR{idProduct}==\""$mIdProduct"\", MODE=\"0600\"" | sudo tee -a /etc/udev/rules.d/51-android.rules
}

addhosts(){
echo -e "安装hosts请按1，还原hosts请按2(此操作会清空hosts文件，请注意!)"
echo -ne "\n选择:"
read hostchoose
case $hostchoose in
	1)
		if [ `grep -rl "203.208.46.146" /etc/hosts` == ""]; then
			echo "203.208.46.146 dl-ssl.google.com" | sudo tee -a /etc/hosts
		elif [ `grep -rl "#203.208.46.146" /etc/hosts` == ""]; then
			echo -e "host已被安装过了"
		else
			echo -e "host曾经被安装过.正在重新安装..."
			sudo sed -i 's\#203.208.46.146\203.208.46.146\g' /etc/hosts
		fi

	;;
	2)
		if [ `grep -rl "#203.208.46.146" /etc/hosts` == ""]; then
			sudo sed -i 's\203.208.46.146\#203.208.46.146\g' /etc/hosts
		else
			echo -e "host已被还原过或者你没有安装过hosts"	
		fi
	;;
esac
}

addRules(){
	clear
	lsusb
	echo -e "\nOK 上面列出了所有USB列表,大致内容如下:"
	echo -e "Bus 00x Device 00x: ID xxxx:xxxx xxxxxxxxxxxxx"
	echo -e "												 ^		^			 ^"
	echo -e "第一个是idVendor,第二个是idProduct,第三个相当于是注释吧"
	echo -e "找第三个里面有没有你的手机厂商的名字,如:HUAWEI,ZTE 什么的"
	echo -e "当然没找到没关系,第三个什么都没有的就是了\n把idVendor和idProduct 打在下面,空格隔开,如:19d2 ffd0"
	echo -ne "\n输入:"
	addRulesFunc
	echo -e "添加成功"
}


addadbrules(){
	echo -e "\n配置adb环境变量..."
	cp 51-android.rules /etc/udev/rules.d/
	chmod a+rx /etc/udev/rules.d/51-android.rules
	source /etc/udev/rules.d/51-android.rules
	echo "export PATH=$PATH:~/bin/" | sudo tee -a /etc/profile
	source /etc/profile
	sudo adb kill-server
	sudo adb devices
	echo "\n配置环境完成"
	echo -e "按回车键继续"
	read anykey
}

changecoronlanguage(){
echo -e "请输入coron项目所在目录(可以尝试把目录拖进来,如果失败请手动输入路径)"
read coronDir
echo -e "输入1即可把coron项目环境改成中文"
echo -e "输入2即可把coron项目环境改回英文"
echo -ne "\n输入(任意字符退出):"
read languagechoose
case $languagechoose in
	1)
		cd $coronDir
		patch -p1<$thisDir/coron.patch
		cd $thisDir
		echo -e "按回车键继续"
		read anykey
	;;
	2)
		cd $coronDir
		patch -R -p1<$thisDir/coron.patch
		cd $thisDir
		echo -e "按回车键继续"
		read anykey
	;;
	*)
		main
	;;
esac
}

zipcenop(){
	echo -e "这是刷机包或者apk&jar伪加密工具"
	echo -e "输入你想加密的刷机包或者apk&jar(可以拖进来)"
	read cenopfile
	echo -ne "\n选择:"
	echo -e "输入1加密，输入2解密，输入任意字符退出"
	echo -ne "\n选择:"
	read cenopmode
case $cenopmode in
	1)
		java -jar $thisDir/ZipCenOp.jar r $cenopfile
	echo -e "按回车键继续"
	read anykey
	;;
	2)
		java -jar $thisDir/ZipCenOp.jar e $cenopfile
	echo -e "按回车键继续"
	read anykey
	;;
	*)
		main
	;;
esac
}

repoSource(){
	mkdir -p ~/bin
 	cp -f repo ~/bin/
 	chmod a+x ~/bin/repo
	clear
	echo -e "------ 同步源码 ------"
	echo -e "请输入存放源码的地址(可直接把文件夹拖进来):"
	echo -ne "\n输入:"
	read sDir
	echo -e "请输入要同步源码的版本号:"
	echo -e "高通(4.0 4.1 4.2 4.3 4.4),联发科(mtk-4.0 mtk-4.2)"
	echo -ne "\n输入:"
	read version
	cd $sDir
	repo init -u https://github.com/baidurom/manifest.git -b "coron-"$($version)
	repo sync
	cd $thisDir
	echo -e "按回车键继续"
	read anykey
}

fastrepoSource(){
	mkdir -p ~/bin
 	cp -f repo ~/bin/
 	chmod a+x ~/bin/repo
	clear
	echo -e "------ 跳过谷歌验证,快速同步源码 ------"
	echo -e "请输入存放源码的地址(可直接把文件夹拖进来):"
	echo -ne "\n输入:"
	read sDir
	echo -e "请输入要同步源码的版本号:"
	echo -e "高通(4.0 4.1 4.2 4.3 4.4),联发科(mtk-4.0 mtk-4.2)"
	echo -ne "\n输入:"
	read version
	cd $sDir
	repo init --repo-url git://github.com/baidurom/repo.git -u https://github.com/baidurom/manifest.git -b "coron-"$($version) --no-repo-verify
	repo sync -c --no-clone-bundle --no-tags -j4
	cd $thisDir
	echo -e "按回车键继续"
	read anykey
}

initSystemConfigure(){
clear
echo -e "请输入你想安装的环境"
echo -e "\t1.ia32运行库"
echo -e "\t2.JavaSE(Oracle Java JDK)"
echo -e "\t3.aosp&cm&recovery编译环境"
echo -e "\t4.adb运行环境"
echo -e "\t5.coron项目中文环境"
echo -e "\t6.hosts环境"
echo -e "\t7.安卓开发必备环境(上面的1.2.3.4)"
echo -ne "\n选择:"
read configurechoose
case $configurechoose in
	1)
		echo -e "\n开始配置32位运行环境..."
		echo -e "请选择使用的系统版本:"
		echo -e "\t1. ubuntu 12.04 及以下"
		echo -e "\t2. 其他(包括deepin等基于ubuntu 的系统)"
		echo -en "选择:"
		read kind
		if [ "$kind" == "1" ]; then
			apt-get install ia32-libs
		else
#start
		cd /etc/apt/sources.list.d #进入apt源列表
		echo "deb http://mirrors.oschina.net/ubuntu/ rarin main restricted universe multiverse" > ia32-libs-raring.list 
#添加ubuntu 13.04的源，因为13.10的后续版本废弃了ia32-libs
		sudo apt-get update #更新一下源
		sudo apt-get install ia32-libs #安装ia32-libs
		rm ia32-libs-raring.list #恢复源
		sudo apt-get update #再次更新下源
#end
		fi
		echo -e "按回车键继续"
		read anykey
	;;
	2)
		sudo apt-get update
		echo -e "\n删除自带的openjdk..."
		sleep 1
		sudo apt-get purge openjdk-* icedtea-* icedtea6-*
		echo -e "\n开始安装oracle java developement kit..."
		sleep 1
		sudo add-apt-repository ppa:webupd8team/java
		sudo apt-get update && sudo apt-get install oracle-java6-installer
		echo -e "按回车键继续"
		read anykey
	;;
	3)
		echo -e "\n开始安装ROM编译环境..."
		echo -e "请选择使用的系统版本:"
		echo -e "\t1. ubuntu 12.04 及以下"
		echo -e "\t2. 其他(包括deepin等基于ubuntu 的系统)"
		echo -en "选择:"
		read kind
		if [ "$kind" == "1" ]; then
			sudo apt-get install bison libc6 build-essential curl flex g++-multilib g++ gcc-multilib git-core gnupg gperf libesd0-dev libncurses5-dev libwxgtk2.8-dev lzop squashfs-tools xsltproc pngcrush schedtool zip zlib1g-dev 
		else
			sudo apt-get install bison libc6 build-essential curl flex g++-multilib g++ gcc-multilib git-core gnupg gperf lib32ncurses5-dev lib32readLine-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop squashfs-tools xsltproc pngcrush schedtool zip zlib1g-dev	
		fi
		read anykey
	;;
	4)
		sudo apt-get install android-tools-adb android-tools-fastboot
		addadbrules
		echo -e "按回车键继续"
		read anykey
	;;
	5)
		changecoronlanguage
	;;
	6)
		addhosts
		echo -e "按回车键继续"
		read anykey
	;;
	7)
		echo -e "\n开始配置32位运行环境..."
		echo -e "请选择使用的系统版本:"
		echo -e "\t1. ubuntu 12.04 及以下"
		echo -e "\t2. 其他(包括deepin等基于ubuntu 的系统)"
		echo -en "选择:"
		read kind
		if [ $kind -eq 1 ]; then
			apt-get install ia32-libs
		else
#start
		cd /etc/apt/sources.list.d #进入apt源列表
		echo "deb http://mirrors.oschina.net/ubuntu/ rarin main restricted universe multiverse" > ia32-libs-raring.list 
#添加ubuntu 13.04的源，因为13.10的后续版本废弃了ia32-libs
		sudo apt-get update #更新一下源
		sudo apt-get install ia32-libs #安装ia32-libs
		rm ia32-libs-raring.list #恢复源
		sudo apt-get update #再次更新下源
#end
		fi
		sudo apt-get update
		echo -e "\n删除自带的openjdk..."
		sleep 1
		sudo apt-get purge openjdk-* icedtea-* icedtea6-*
		echo -e "\n开始安装oracle java developement kit..."
		sleep 1
		sudo add-apt-repository ppa:webupd8team/java
		sudo apt-get update && sudo apt-get install oracle-java6-installer
		sudo apt-get install android-tools-adb android-tools-fastboot
		echo -e "\n开始安装ROM编译环境..."
		sudo apt-get install bison build-essential curl flex g++-multilib g++ gcc-multilib git-core gnupg gperf lib32ncurses5-dev lib32readLine-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop squashfs-tools xsltproc pngcrush schedtool zip zlib1g-dev
		echo -e "\n配置adb环境变量..."
		cp 51-android.rules /etc/udev/rules.d/
		sudo chmod a+rx /etc/udev/rules.d/51-android.rules
		source /etc/udev/rules.d/51-android.rules
		echo "export PATH=$PATH:~/bin/" | sudo tee -a /etc/profile
		source /etc/profile
		sudo adb kill-server
		sudo adb devices
		echo "\n配置环境完成"
		echo -e "按回车键继续"
		read anykey
	;;
esac
}

logcat(){
echo -e "这是抓取log的工具，过程中按ctrl+c退出"
echo -e "输入1将把所有的log输出到$thisDir/log"
echo -e "输入2把你想过滤的内容输出到终端并保存到文件"
echo -ne "\n选择:"
read logcatmode
case $logcatmode in
	1)
		adb logcat > $thisDir/log
	;;
	2)
		echo -e "输入你想过滤的内容"
		read ignoretext
		adb logcat|grep $ignoretext|tee $thisDir/log
	;;
	*)
		echo -e "请输入正确的命令"
		sleep 2
	;;
esac
}

clean(){
	echo -e "正在清理残留文件"
	rm -rf log
	rm -rf screenshot.png
	echo -e "按回车键退出"
	read anykey
}
 
main(){
clear 
echo -e "                 Android Development Shell scirpt"
echo "          --made by Modificator & Edit by Jay_Kwan"
echo -e "			输入命令号码 :\n"
echo -e "\t\t1. 使用root权限启动adb"
echo -e "\t\t2. 设置环境变量"
echo -e "\t\t3. 依然无法识别手机？没关系，选这个"
echo -e "\t\t4. 同步源码"
echo -e "\t\t5. 快速同步源码(跳过谷歌认证)"
echo -e "\t\t6. 伪加密工具"
echo -e "\t\t7. 抓取log工具"
echo -e "\t\t8. 手机截图"
echo -e "\t\t0. 离开脚本"
echo -ne "\n选择:"
read inp
case $inp in
	1)
		sudo adb kill-server
		sudo adb devices
		echo -e "按回车键继续"
		read anykey
		main
	;;
	2)
		initSystemConfigure
		main
	;;
	3)
		addRules
		main
	;;
	4)
		repoSource
		main
	;;
	5)
		fastrepoSource
		main
	;;
	6)
		zipcenop
		main
	;;
	7)
		logcat
		main
	;;
	8)
		adb shell /system/bin/screencap -p /data/local/tmp/screenshot.png
		cd $thisDir
		adb pull /data/local/tmp/screenshot.png
		if [ "$?" == "0" ]; then
		echo -e "截图文件已经输出到$thisDir"
		fi
		echo -e "按回车键继续"
		read anykey
		main
	;;
	0)
		cd $thisDir
		echo -e "正在清理环境文件"
		rm -rf repo 51-android.rules coron.patch ZipCenOp.jar
		echo -e "输入c清理残留文件否则直接退出"
		echo -ne "\n输入c清理或者按回车退出:"
		read cleanchoose
		if [ "$cleanchoose" -eq "c" ]; then
			clean
		fi
		echo -e "\e[0m"
	;;
	*)
	main
	;;
esac
}
echo -e "正在解压工具，请稍候......"
if [ ! -f repo ]; then 
	tar -xvf tools.tar
fi 

sleep 1
main
echo -e "\e[0m"