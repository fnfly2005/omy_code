#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
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
        sum(fp0.first_uv) as first_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            dt,
            app_name,
            approx_distinct(case when nav_flag=1 then union_id end) as first_uv,
            approx_distinct(case when nav_flag=2 then union_id end) as detail_uv,
            approx_distinct(case when nav_flag=4 then union_id end) as order_uv
        from (
            select
                partition_date as dt,
                app_name,
                page_identifier,
                union_id
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date>='\$\$monthfirst{-1m}'
                and partition_date<'\$\$monthfirst'
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
            app_name
        ) as fp0
        left join (
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
            spo.dt,
            spo.sellchannel,
            count(distinct spo.order_id) as order_num
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
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"
