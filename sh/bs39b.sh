#!/bin/bash
#格瓦拉平台产品数据复盘
source ./fuc.sh

mpw=`fun detail_myshow_pv_wide_report.sql ud`
file="bs39"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    partition_date as dt,
    approx_distinct(union_id) as dau
$mpw
where
    partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and app_name='gewara'
    and partition_biz_bg=0
    and page_name_my='平台首页'
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
