#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
mdk=`fun topic_movie_deal_kpi_daily.sql`
mp=`fun myshow_pv.sql`
md=`fun myshow_dictionary.sql`

file="bs16"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp3.dt,
    sp3.bu,
    fp2.uv,
    sp3.order_num,
    sp3.ticket_num,
    sp3.totalprice
from (
    select
        dt,
        coalesce(bu,'全部') as bu,
        sum(order_num) as order_num,
        sum(ticket_num) as ticket_num,
        sum(totalprice) as totalprice
    from (
        select
            spo.dt,
            '演出' as bu,
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice
        from
            (
            $spo
            and sellchannel=8
            ) spo
        group by
            spo.dt,
            '演出'
        union all
        select
            dt,
            '电影' as bu,
            mdk.order_num,
            mdk.ticket_num,
            mdk.gmv as totalprice
        from (
            $mdk
            ) as mdk
        ) as sp1
    group by
        dt,
        bu
    grouping sets(
        dt,
        (dt,bu)
        )
    ) as sp3
    left join (
        select
            dt,
            coalesce(bu,'全部') as bu,
            count(distinct union_id) as uv
        from (
            select
                dt,
                coalesce(md.value1,'平台') as bu,
                union_id
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
                group by
                    partition_date,
                    page_identifier,
                    union_id
                ) as fpw
                left join (
                    $mp
                    and page='native'
                    and page_tag1<>-1
                    ) as mp
                on fpw.page_identifier=mp.value
                left join (
                    $md
                    and key_name='page_tag1'
                    and key in (-2,0)
                    ) as md
                on mp.page_tag1=md.key
            group by
                dt,
                coalesce(md.value1,'平台'),
                union_id
            ) as fp1
        group by
            dt,
            bu
        grouping sets (
            dt,
            (dt,bu)
            )
    ) as fp2
    on sp3.dt=fp2.dt
    and sp3.bu=fp2.bu
$lim">${attach}

echo "succuess,detail see ${attach}"

