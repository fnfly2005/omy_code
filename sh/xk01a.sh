#!/bin/bash
source ./fuc.sh

file="xk01"

spo=`fun detail_myshow_salepayorder.sql tu`
ss=`fun detail_myshow_salesplan.sql t`
mpw=`fun detail_myshow_pv_wide_report.sql ut`
md=`fun myshow_dictionary.sql`

lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ss1.dt,
    ss1.ap_num,
    ss1.as_num,
    sp1.sp_num,
    sp1.order_num,
    sp1.uv_order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    fpw.uv
from (
    select
        ss.dt,
        count(distinct ss.performance_id) as ap_num,
        count(distinct ss.salesplan_id) as as_num
    from (
        $ss
        and salesplan_sellout_flag=0
        ) ss
    group by
        ss.dt
    ) as ss1
    left join (
    select
        dt,
        count(distinct performance_id) as sp_num,
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
            sum(setnumber*salesplan_count) as ticket_num,
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
        1
    ) as sp1
    on sp1.dt=ss1.dt
    left join (
        select
            partition_date as dt,
            count(distinct union_id) as uv
        $mpw
        group by
            1
        ) as fpw
    on ss1.dt=fpw.dt
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
