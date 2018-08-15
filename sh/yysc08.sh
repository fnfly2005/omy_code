#!/bin/bash
source ./fuc.sh
spo=`fun detail_myshow_salepayorder.sql u`
dp=`fun dim_myshow_performance.sql`
fp=`fun detail_flow_pv_wide_report.sql`
md=`fun myshow_dictionary.sql`
mpw=`fun detail_myshow_pv_wide_report.sql u`

file="yysc08"
lim=";"
attach="${path}doc/${file}.sql"
performance_name='$performance_name'

echo "
select
    vp.dt,
    vp.ht,
    vp.mit,
    vp.pt,
    vp.page_city_name,
    dp.city_name,
    dp.category_name,
    dp.shop_name,
    dp.performance_id,
    dp.performance_name,
    vp.uv,
    case when sp.performance_id is null then 0
    else sp.order_num end as order_num,
    case when sp.performance_id is null then 0
    else sp.ticket_num end as ticket_num, 
    case when sp.performance_id is null then 0
    else sp.totalprice end as totalprice,
    case when sp.performance_id is null then 0
    else sp.grossprofit end as grossprofit
from (
    $dp
        and (regexp_like(performance_name,'\$performance_name')
        or '测试'='\$performance_name')
        and (performance_id in (\$performance_id)
        or -99 in (\$performance_id))
        ) as dp
    join (
    select
        dt,
        ht,
        mit,
        value2 as pt,
        page_city_name,
        performance_id,
        sum(uv) uv
    from (
        select
            case when 1 in (\$dim) then partition_date 
            else 'all' end as dt,
            case when 2 in (\$dim) then substr(stat_time,12,2) 
            else 'all' end as ht,
            case when 3 in (\$dim) then (cast(substr(stat_time,15,1) as bigint)+1)*10
                when 30 in (\$dim) then substr(stat_time,15,2)
            else 'all' end as mit,
            case when 4 in (\$dim) then app_name
            else 'all' end as app_name,
            case when 5 in (\$dim) then page_city_name
            else 'all' end as page_city_name,
            performance_id,
            count(distinct union_id) uv
        $mpw
            and page_name_my='演出详情页'
            and (performance_id in (\$performance_id)
            or -99 in (\$performance_id))
            and (2 in (\$dim)
                or 3 in (\$dim)
                )
            and substr(stat_time,12,2)>=\$hts
            and substr(stat_time,12,2)<\$hte
        group by
            1,2,3,4,5,6
        union all
        select
            case when 1 in (\$dim) then partition_date 
            else 'all' end as dt,
            'all' as ht,
            'all' as mit,
            case when 4 in (\$dim) then app_name
            else 'all' end as app_name,
            case when 5 in (\$dim) then page_city_name
            else 'all' end as page_city_name,
            performance_id,
            count(distinct union_id) uv
        $mpw
            and page_name_my='演出详情页'
            and (performance_id in (\$performance_id)
            or -99 in (\$performance_id))
            and 2 not in (\$dim)
            and 3 not in (\$dim)
        group by
            1,2,3,4,5,6
        ) fp
        left join (
        $md
        and key_name='app_name'
        ) md
        on md.key=fp.app_name
    group by
        1,2,3,4,5,6
    ) vp
    on vp.performance_id=dp.performance_id
    left join (
        select
            dt,
            ht,
            mit,
            md.value2 pt,
            performance_id,
            sum(order_num) order_num,
            sum(ticket_num) ticket_num,
            sum(totalprice) totalprice,
            sum(grossprofit) grossprofit
        from (
            select
                case when 1 in (\$dim) then partition_date
                else 'all' end as dt,
                case when 2 in (\$dim) then substr(pay_time,12,2)
                else 'all' end as ht,
                case when 3 in (\$dim) then (cast(substr(pay_time,15,1) as bigint)+1)*10
                else 'all' end as mit,
                case when 4 in (\$dim) then sellchannel
                else -99 end as sellchannel,
                performance_id,
                count(distinct order_id) order_num,
                sum(salesplan_count*setnumber) ticket_num,
                sum(totalprice) totalprice,
                sum(grossprofit) grossprofit
            $spo
                and sellchannel not in (9,10,11)
                and (performance_id in (\$performance_id)
                or -99 in (\$performance_id))
                and (2 in (\$dim)
                    or 3 in (\$dim)
                    )
                and substr(pay_time,12,2)>=\$hts
                and substr(pay_time,12,2)<\$hte
            group by
                1,2,3,4,5
            union all
            select
                case when 1 in (\$dim) then partition_date
                else 'all' end as dt,
                'all' as ht,
                'all' as mit,
                case when 4 in (\$dim) then sellchannel
                else -99 end as sellchannel,
                performance_id,
                count(distinct order_id) order_num,
                sum(salesplan_count*setnumber) ticket_num,
                sum(totalprice) totalprice,
                sum(grossprofit) grossprofit
            $spo
                and sellchannel not in (9,10,11)
                and (performance_id in (\$performance_id)
                or -99 in (\$performance_id))
                and 2 not in (\$dim)
                and 3 not in (\$dim)
            group by
                1,2,3,4,5
                ) as spo
            left join (
            $md
            and key_name='sellchannel'
            ) md
            on md.key=spo.sellchannel
        group by
            1,2,3,4,5
        ) sp
    on sp.performance_id=vp.performance_id
    and sp.dt=vp.dt
    and sp.ht=vp.ht
    and sp.mit=vp.mit
    and sp.pt=vp.pt
    and 5 not in (\$dim)
where
    vp.pt in (\$pt)
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
