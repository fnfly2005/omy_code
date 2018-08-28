#!/bin/bash
#营销短信标识上传数据监控
source ./fuc.sh

msu=`fun detail_myshow_msuser.sql ut`
file="bi10"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sendtag,
    count(1) as num
$msu
group by
    1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
