#!/bin/bash
#格瓦拉平台日报a-日期/业务单元/UV/订单/出票/销售
source ./fuc.sh
spo=`fun detail_myshow_salepayorder.sql ut`
fmw=`fun detail_flow_mv_wide_report.sql ut`
mdk=`fun topic_movie_deal_kpi_daily.sql ut`
mp=`fun myshow_pv.sql`
md=`fun myshow_dictionary.sql`

file="xk02"
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
            sum(ticket_num) as ticket_num,
            sum(spo.totalprice) as totalprice
        from (
            select
                partition_date as dt,
                order_id,
                salesplan_count*setnumber as ticket_num,
                totalprice
            $spo
                and sellchannel=8
            union all
            select
                fmw.dt,
                fmw.order_id,
                ticket_num,
                totalprice
            from (
                select distinct
                    partition_date as dt,
                    order_id
                $fmw
                    and utm_source='gewara_pc'
                    and event_id='b_w047f3uw'
                ) as fmw
                left join (
                    select
                        partition_date as dt,
                        order_id,
                        salesplan_count*setnumber as ticket_num,
                        totalprice
                    $spo
                        and sellchannel=7
                    ) as fso
                on fmw.order_id=fso.order_id
                and fmw.dt=fso.dt
            ) spo
        group by
            spo.dt,
            '演出'
        union all
        select
            '\$\$today{-1d}' as dt,
            '电影' as bu,
            sum(ordernum) as order_num,
            sum(seatnum) as ticket_num,
            sum(gmv) as totalprice
        $mdk
        group by
            '\$\$today{-1d}',
            '电影'
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
                where partition_date='\$\$today{-1d}'
                    and partition_log_channel='movie'
                    and partition_app='other_app'
                    and app_name in ('gewara','gewara_pc')
                group by
                    partition_date,
                    page_identifier,
                    union_id
                ) as fpw
                left join (
                    $mp
                    and page in ('native','pc')
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

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
