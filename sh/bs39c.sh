#!/bin/bash
#格瓦拉平台产品数据复盘
source ./fuc.sh

fmw=`fun detail_flow_mv_wide_report.sql u`
file="bs39"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    partition_date as dt,
    approx_distinct(union_id) as uv
$fmw
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier='c_f740bkf7'
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
