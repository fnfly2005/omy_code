#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

per=`fun dim_myshow_performance.sql` 
fpw=`fun detail_flow_pv_wide_report.sql`
spo=`fun detail_myshow_salepayorder.sql`

file="yysc04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp1.dt, 
    sp1.plat,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    fpw.uv,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit
from (
    select
        spo.dt,
        case when sellchannel<>8 then 'other'
            else 'gewara'
        end as plat,
        performance_id,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from
        (
        $spo
        ) spo
    group by
        1,2
    ) as sp1
    left join (
    $per
    ) as per
    on per.performance_id=sp1.performance_id
    left join (
        select
            partition_date as dt,
            'other' as plat,
            case when app_name='maoyan_wxwallet_i' then custom['id'] 
            else custom['performance_id'] end as performance_id,
            approx_distinct(union_id) as uv
        from mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie','dianping_nova','other_app','dp_m','group'
            )
            and app_name<>'gewara'
            and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier'
            and nav_flag=2
            and page in ('h5','mini_programs')
            )
        group by
            1,2,3
        ) as fpw
    on sp1.dt=fpw.dt
    and sp1.performance_id=fpw.performance_id
    and sp1.plat=fpw.plat
$lim">${attach}

echo "succuess,detail see ${attach}"
