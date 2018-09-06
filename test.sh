#!/bin/bash
source ./fuc.sh
tes=`fun sql/detail_myshow_salepayorder.sql`

file="test"
lim=";"
attach="${path}doc/${file}.sql"
mt1="upload_table."
mt2="mart_movie."

echo "
$tes"

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
