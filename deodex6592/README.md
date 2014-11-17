
使用前请确保：
1. 请确保你的Linux系统安装了Java环境，JDK版本要大于1.6，需要配置好环境变量。
2. 确保你的系统安装了zip命令。


使用时将ROM包中的app和framework文件夹全部拷贝到该工具的system目录下面，然后在该工具的根目录运行：
./deodex_mtk6592.sh
运行过程中你可能会发现屏幕打印出异常，这个是正常的，耐心等待合并完成即可。当system/app和system/framework文件夹下面都没有odex文件时表示合并成功。

