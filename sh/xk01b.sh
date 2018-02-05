#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
ss=`fun detail_myshow_salesplan.sql`
md=`fun myshow_dictionary.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.pt,
    fp1.pv,
    fp1.uv,
    sp1.order_num,
    sp1.totalprice
from (
    select
        fpw.dt,
        md.value2 as pt,
        sum(fpw.uv) as uv,
        sum(fpw.pv) as pv
    from (
        select
            partition_date as dt,
            app_name,
            count(distinct union_id) as uv,
            count(1) as pv
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$time1'
            and partition_date<'\$time2'
            and partition_log_channel='movie'
            and partition_app in (
            select key
            from upload_table.myshow_dictionary
            where key_name='partition_app'
            )
            and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier'
            and page_tag1>=0
            )
        group by
            partition_date,
            app_name
        ) as fpw
    left join (
        $md
        and key_name='app_name'
        ) md
    on fpw.app_name=md.key
    group by
        fpw.dt,
        md.value2
    ) as fp1
    left join (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num,
        sum(sp0.totalprice) as totalprice
    from (
        select
            spo.dt,
            spo.sellchannel,
            count(distinct spo.order_id) as order_num,
            sum(spo.totalprice) as totalprice
        from
            (
            $spo
            ) spo
        group by
            spo.dt,
            spo.sellchannel
        ) as sp0
        left join
        (
        $md
        and key_name='sellchannel'
        ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
$lim">${attach}

echo "succuess,detail see ${attach}"

