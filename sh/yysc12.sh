#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql`

file="yysc12"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.ht,
    fp1.pt,
    fp1.first_uv,
    fp1.detail_uv,
    fp1.order_uv,
    sp1.order_num
from (
    select
        dt,
        ht,
        md.value2 as pt,
        sum(fp0.first_uv) as first_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            dt,
            ht,
            app_name,
            approx_distinct(case when nav_flag=1 then union_id end) as first_uv,
            approx_distinct(case when nav_flag=2 then union_id end) as detail_uv,
            approx_distinct(case when nav_flag=4 then union_id end) as order_uv
        from (
            select
                partition_date as dt,
                substr(stat_time,12,2) as ht,
                app_name,
                page_identifier,
                union_id
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date='\$\$today{-1d}'
                and partition_log_channel='movie'
                and partition_app in (
                'movie',
                'dianping_nova',
                'other_app',
                'dp_m',
                'group'
                )
                and page_identifier in (
                select value
                from upload_table.myshow_pv
                where key='page_identifier'
                and page_tag1>=0
                )
            ) as fpw
            left join (
                $mp
                and page_tag1>=0
                ) mp
            on mp.value=fpw.page_identifier
        group by
            dt,
            ht,
            app_name
        ) as fp0
        left join (
            $md
            and key_name='app_name'
            ) md
        on fp0.app_name=md.key
    group by
        dt,
        ht,
        value2
    ) as fp1
    left join (
    select
        sp0.dt,
        sp0.ht,
        md.value2 as pt,
        sum(sp0.order_num) as order_num
    from (
        select
            spo.dt,
            substr(pay_time,12,2) as ht,
            spo.sellchannel,
            count(distinct spo.order_id) as order_num
        from
            (
            $spo
            ) spo
        group by
            spo.dt,
            substr(pay_time,12,2),
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
        sp0.ht,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
    and sp1.ht=fp1.ht
$lim">${attach}

echo "succuess,detail see ${attach}"
