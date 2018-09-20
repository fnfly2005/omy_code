#!/bin/bash
#项目流量-多维度-多指标
source ./fuc.sh
spo=`fun detail_myshow_salepayorder.sql u`
dp=`fun dim_myshow_performance.sql`
fp=`fun detail_flow_pv_wide_report.sql`
md=`fun sql/dim_myshow_dictionary.sql`
mpw=`fun detail_myshow_pv_wide_report.sql u`
out=`fun sql/detail_myshow_stockout.sql u`
ush=`fun sql/dp_myshow__s_messagepush.sql`

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
    coalesce(sp.order_num,0) as order_num,
    coalesce(sp.ticket_num,0) as ticket_num, 
    coalesce(sp.totalprice,0) as totalprice,
    coalesce(sp.grossprofit,0) as grossprofit,
    coalesce(ush_num,0) as ush_num,
    coalesce(out_num,0) as out_num
from (
    $dp
        and (regexp_like(performance_name,'\$performance_name')
        or '全部'='\$performance_name')
        and (performance_id in (\$performance_id)
        or -99 in (\$performance_id))
        ) as dp
    join (
    select
        dt,
        ht,
        mit,
        case when 4 in (\$dim) then value2
        else '全部' end as pt,
        page_city_name,
        performance_id,
        sum(uv) uv
    from (
        select
            case when 1 in (\$dim) then partition_date 
            else 'all' end as dt,
            case when 2 in (\$dim) then substr(stat_time,12,2) 
            else 'all' end as ht,
            case when 3 in (\$dim) then (floor(cast(substr(stat_time,15,2) as double)/\$tie)+1)*\$tie
            else 'all' end as mit,
            app_name,
            case when 5 in (\$dim) then page_city_name
            else 'all' end as page_city_name,
            performance_id,
            count(distinct union_id) uv
        $mpw
            and page_name_my='演出详情页'
            and (performance_id in (\$performance_id)
            or -99 in (\$performance_id))
            and ((substr(stat_time,12,2)>=\$hts and substr(stat_time,12,2)<\$hte)
                or (2 not in (\$dim) and 3 not in (\$dim)))
        group by
            1,2,3,4,5,6
        ) fp
        join (
            $md
                and key_name='app_name'
                and value2 in (\$pt)
            ) md
        on md.key=fp.app_name
    group by
        1,2,3,4,5,6
    ) vp
    on vp.performance_id=dp.performance_id
    left join (
        select
            case when 1 in (\$dim) then partition_date
            else 'all' end as dt,
            case when 2 in (\$dim) then substr(pay_time,12,2)
            else 'all' end as ht,
            case when 3 in (\$dim) then (floor(cast(substr(pay_time,15,2) as double)/\$tie)+1)*\$tie
            else 'all' end as mit,
            case when 4 in (\$dim) then md.value2
            else '全部' end as pt,
            performance_id,
            count(distinct order_id) order_num,
            sum(ticket_num) ticket_num,
            sum(totalprice) totalprice,
            sum(grossprofit) grossprofit
        from (
            select
                partition_date,
                pay_time,
                sellchannel,
                performance_id,
				order_id,
				(salesplan_count*setnumber) as ticket_num,
				totalprice,
				grossprofit
            $spo
                and (performance_id in (\$performance_id)
                or -99 in (\$performance_id))
                and ((substr(pay_time,12,2)>=\$hts and substr(pay_time,12,2)<\$hte)
                    or (2 not in (\$dim) and 3 not in (\$dim)))
                ) as spo
            join (
                $md
                and key_name='sellchannel'
                and value2 in (\$pt)
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
    left join (
        select
            case when 1 in (\$dim) then substr(createtime,1,10)
            else 'all' end as dt,
            case when 2 in (\$dim) then substr(createtime,12,2)
            else 'all' end as ht,
            case when 3 in (\$dim) then (floor(cast(substr(createtime,15,2) as double)/\$tie)+1)*\$tie
            else 'all' end as mit,
            case when 4 in (\$dim) then md.value2
            else '全部' end as pt,
            performance_id,
            count(distinct mobile) as ush_num
        from (
            $ush
                and (performanceid in (\$performance_id)
                or -99 in (\$performance_id))
                and ((substr(createtime,12,2)>=\$hts and substr(createtime,12,2)<\$hte)
                    or (2 not in (\$dim) and 3 not in (\$dim)))
            ) ush
            join (
                $md
                    and key_name='sellchannel'
                    and value2 in (\$pt)
                ) md
            on ush.sellchannel=md.key
        group by
            1,2,3,4,5
        ) us
    on us.performance_id=vp.performance_id
    and us.dt=vp.dt
    and us.ht=vp.ht
    and us.mit=vp.mit
    and us.pt=vp.pt
    and 5 not in (\$dim)
    left join (
        select
            case when 1 in (\$dim) then substr(createtime,1,10)
            else 'all' end as dt,
            case when 2 in (\$dim) then substr(createtime,12,2)
            else 'all' end as ht,
            case when 3 in (\$dim) then (floor(cast(substr(createtime,15,2) as double)/\$tie)+1)*\$tie
            else 'all' end as mit,
            case when 4 in (\$dim) then md.value2
            else '全部' end as pt,
            performance_id,
            count(distinct mobile) as out_num
        from (
            select
                createtime,
                performance_id,
                sellchannel,
                mobile
            $out
                and (performance_id in (\$performance_id)
                or -99 in (\$performance_id))
                and ((substr(createtime,12,2)>=\$hts and substr(createtime,12,2)<\$hte)
                    or (2 not in (\$dim) and 3 not in (\$dim)))
            ) out
            join (
                $md
                    and key_name='sellchannel'
                    and value2 in (\$pt)
                ) md
            on out.sellchannel=md.key
        group by
            1,2,3,4,5
        ) ou
    on ou.performance_id=vp.performance_id
    and ou.dt=vp.dt
    and ou.ht=vp.ht
    and ou.mit=vp.mit
    and ou.pt=vp.pt
    and 5 not in (\$dim)
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
