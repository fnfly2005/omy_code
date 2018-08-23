#!/bin/bash
source ./fuc.sh
mpw=`fun detail_myshow_pv_wide_report.sql ut`
spo=`fun detail_myshow_salepayorder.sql ut`
ss=`fun detail_myshow_salesplan.sql t`
per=`fun dim_myshow_performance.sql`
md=`fun myshow_dictionary.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp1.dt,
    per.performance_name,
    sp1.order_num,
    sp1.uv_order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    fpw.uv
from (
    select
        dt,
        performance_id,
        order_num,
        uv_order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (partition by dt order by totalprice desc) as rank
    from (
        select
            dt,
            performance_id, 
            sum(order_num) as order_num,
            sum(case when key1='1' then order_num end) as uv_order_num,
            sum(ticket_num) as ticket_num,
            sum(totalprice) as totalprice,
            sum(grossprofit) as grossprofit
        from (
            select
                partition_date as dt,
                sellchannel,
                performance_id, 
                count(distinct order_id) as order_num,
                sum(salesplan_count*setnumber) as ticket_num,
                sum(totalprice) as totalprice,
                sum(grossprofit) as grossprofit
            $spo
            group by
                1,2,3
            ) as spo
            join (
            $md
                and key_name='sellchannel'
                and key1<>'0'
            ) as md
            on spo.sellchannel=md.key
        group by
            1,2
        ) as sp0
    ) as sp1
    left join (
        select
            partition_date as dt,
            performance_id,
            count(distinct union_id) as uv
        $mpw
            and page_name_my='演出详情页'
        group by
            1,2
        ) as fpw
    on sp1.dt=fpw.dt 
    and sp1.performance_id=fpw.performance_id
    and sp1.rank<=10
    left join (
    $per
    ) as per
    on per.performance_id=sp1.performance_id
    and sp1.rank<=10
where
    sp1.rank<=10
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
