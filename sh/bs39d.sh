#!/bin/bash
#格瓦拉平台产品数据复盘
source ./fuc.sh

ily=`fun sql/topic_movie_deal_kpi_daily.sql u`
file=`echo $0 | sed "s/[a-z]*\.sh//g;s/.*\///g"`
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(date_parse(dt,'%Y%m%d'),1,10) as dt,
    sum(ordernum) as ordernum,
    sum(seatnum) as seatnum,
    sum(gmv) as gmv
$ily
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
