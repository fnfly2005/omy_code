#!/bin/bashs
#数据字典-日报
source ./fuc.sh
mds=`fun dim_myshow_dictionary.sql` 

file="xk06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
$mds
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


