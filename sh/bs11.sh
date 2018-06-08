#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}
my=`fun aggr_movie_dau_client_core_page_daily.sql` 
dp=`fun aggr_movie_dianping_app_conversion_daily.sql`
wxycss=`fun aggr_movie_maoyan_weixin_daily.sql`
mt=`fun aggr_movie_meituan_app_conversion_daily.sql`
wxchwl=`fun aggr_movie_weixin_app_conversion_daily.sql`
file="bs11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 1 in (\$dim) then dt
    else 'all' end as dt,
    pt,
    avg(uv) uv
from (
    select
        dt,
        case when 2 in (\$dim) then pt
        else 'all' end as pt,
        sum(firstpage_uv) as uv
    from (
        $my
        union all
        $dp
        union all
        $wxycss
        union all
        $mt
        union all
        $wxchwl
        ) as u 
    group by 
        1,2
    ) as su
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
