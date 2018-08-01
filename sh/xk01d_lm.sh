#!/bin/bash
path=""
fun() {
    tmp=`cat ${path}sql/${1} | grep -iv "/\*"`
    if [ -n $2 ];then
        if [[ $2 =~ d ]];then
            tmp=`echo $tmp | sed 's/where.*//'`
        fi
        if [[ $2 =~ u ]];then
            tmp=`echo $tmp | sed 's/.*from/from/'`
        fi
        if [[ $2 =~ t ]];then
            tmp=`echo $tmp | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
        fi
        if [[ $2 =~ m ]];then
            tmp=`echo $tmp | sed "s/begindate/monthfirst{-1m}/g;s/enddate/monthfirst/g"`
        fi
    fi
    echo $tmp
}

mpw=`fun detail_myshow_pv_wide_report.sql um`
spo=`fun detail_myshow_salepayorder.sql mu`
md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(fp1.dt,1,7) mt,
    fp1.pt,
    avg(fp1.first_uv) first_uv,
    avg(fp1.detail_uv) detail_uv,
    avg(fp1.order_uv) order_uv,
    avg(sp1.order_num) order_num
from (
    select
        dt,
        coalesce(md.value2,'其他') as pt,
        sum(case when page_cat=1 then uv end) as first_uv,
        sum(case when page_cat=2 then uv end) as detail_uv,
        sum(case when page_cat=3 then uv end) as order_uv
    from (
        select
            partition_date as dt,
            app_name,
            page_cat,
            approx_distinct(union_id) as uv
        $mpw
            and page_cat<>4
        group by
            1,2,3
        ) as fp0
        left join (
            $md
            and key_name='app_name'
            ) md
        on fp0.app_name=md.key
    group by
        1,2
    ) as fp1
    left join (
        select
            sp0.dt,
            md.value2 as pt,
            sum(sp0.order_num) as order_num
        from (
            select
                partition_date as dt,
                sellchannel,
                count(distinct order_id) as order_num
            $spo
                and sellchannel not in (9,10,11)
            group by
                1,2
            ) as sp0
            left join (
                $md
                and key_name='sellchannel'
                ) as md
            on sp0.sellchannel=md.key
        group by
            1,2
        ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
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
