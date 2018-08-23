#!/bin/bash
source ./fuc.sh

spo=`fun detail_myshow_salepayorder.sql ut`
mpw=`fun detail_myshow_pv_wide_report.sql ut`
md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.pt,
    fp1.first_uv,
    fp1.detail_uv,
    fp1.order_uv,
    sp1.order_num
from (
    select
        dt,
        md.value2 as pt,
        sum(fp0.first_uv) as first_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            partition_date as dt,
            app_name,
            count(distinct case when page_name_my='演出首页' then union_id end) as first_uv,
            count(distinct case when page_name_my='演出详情页' then union_id end) as detail_uv,
            count(distinct case when page_name_my='演出确认订单页' then union_id end) as order_uv
        $mpw
            and page_name_my in ('演出首页','演出详情页','演出确认订单页')
        group by
            partition_date,
            app_name
        ) as fp0
        join (
            $md
            and key_name='app_name'
            ) md
        on fp0.app_name=md.key
    group by
        dt,
        value2
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
        group by
            partition_date,
            sellchannel
        ) as sp0
        join (
            $md
            and key_name='sellchannel'
            and key1='1'
            ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
