#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql`
mck=`fun topic_movie_deal_kpi_daily.sql`

file="bs16"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.first_uv,
    fp1.nav_uv,
    fp1.detail_uv,
    fp1.order_uv,
    sp1.order_num
from (
    select
        dt,
        sum(fp0.first_uv) as first_uv,
        sum(fp0.nav_uv) as nav_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            dt,
            count(distinct case when nav_flag=0 then union_id end) as first_uv,
            count(distinct case when nav_flag=1 then union_id end) as nav_uv,
            count(distinct case when nav_flag=2 then union_id end) as detail_uv,
            count(distinct case when nav_flag=4 then union_id end) as order_uv
        from (
            select
                partition_date as dt,
                page_identifier,
                union_id
            from
                mart_flow.detail_flow_pv_wide_report
            where partition_date>='\$\$begindate'
                and partition_date<'\$\$enddate'
                and partition_log_channel='movie'
                and partition_app='other_app'
                and app_name='gewara'
                and page_identifier in (
                select value
                from upload_table.myshow_pv
                where key='page_identifier'
                and page='native'
                and page_tag1>-2
                )
            group by
                partition_date,
                page_identifier,
                union_id
            ) as fpw
            left join (
                $mp
                and page='native'
                and page_tag1>-2
                ) mp
            on mp.value=fpw.page_identifier
        group by
            dt
        ) as fp0
    group by
        dt
    ) as fp1
    left join (
        select
            spo.dt,
            count(distinct spo.order_id) as order_num
        from (
            $spo
            and sellchannel=8
            ) spo
        group by
            spo.dt
    ) as sp1
    on sp1.dt=fp1.dt
$lim">${attach}

echo "succuess,detail see ${attach}"
