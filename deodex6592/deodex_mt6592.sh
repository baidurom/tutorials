#!/bin/sh
echo "This is a tool to deodex files for the MTK6592 platform."

TOOLS_DIR=tools
cp -rf system/framework system/temp_framework


deodex_file()
{
if [ ! -d $1 ]
then 
echo "ERROR: dir $1 doesn't exist!"
exit 1
fi

echo "Deodex file in $1"
for file in `find $1/*.odex`; 
do
echo "Deodex $file..."
useVersion=2.0.3

java -Xmx512m -jar $TOOLS_DIR/baksmali-2.0.3.jar -a 17 -d system/temp_framework -x $file

if [ $? != 0 ]
then
java -Xmx512m -jar $TOOLS_DIR/baksmali-1.4.2.jar -T $TOOLS_DIR/inline.txt -a 17 -d system/temp_framework -x $file
useVersion=1.4.2
fi

if [ $? != 0 ]
then 
  	echo "Deodex $file failed!"
fi

#make classes.dex
if [ -d out ]
then 
echo "making classes.dex"
java -Xmx512m -jar $TOOLS_DIR/smali-$useVersion.jar -a 17 -o classes.dex out
fi


if [ -f classes.dex ]
then 
newfile=${file%odex}jar
if [ "$1" = "system/app" ]
then 
newfile=${file%odex}apk
fi

echo "Adding classes.dex to $newfile"
zip -m $newfile classes.dex
#remove the odex file
rm $file
fi


#delete the out tmp dir
rm -rf out
echo "Deode $file completed!"
echo 


done

echo `ls -l *.odex|grep "^-"|wc -l` "odex remained in $1!"
echo "Deodex $1 completed!"
}


deodex_file "system/framework"

deodex_file "system/app"

rm -rf system/temp_framework
