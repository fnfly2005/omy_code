#!/bin/bash
#历史流量-全量-多维度-多指标
source ./fuc.sh

spo=`fun detail_myshow_salepayorder.sql u`
md=`fun sql/dim_myshow_dictionary.sql`
mdc=`fun sql/dim_myshow_dictionary.sql u`
mpw=`fun detail_myshow_pv_wide_report.sql u`
ort=`fun detail_myshow_pv_wide_report.sql ud`

file="bs34"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 1 in (\$dim) then sp1.dt
    else 'all' end as dt,
    sp1.pt,
    avg(all_uv) as all_uv,
    avg(fp1.first_uv) as first_uv,
    avg(fp1.detail_uv) as detail_uv,
    avg(fp1.order_uv) as order_uv,
    avg(sp1.order_num) as order_num,
    avg(totalprice) as totalprice,
    avg(ticket_num) as ticket_num,
    avg(grossprofit) as grossprofit,
    avg(list_uv) as list_uv,
    avg(pt_uv) as pt_uv
from (
    select
        sp0.dt,
        case when 2 in (\$dim) then md.value2
        else '全部' end as pt,
        sum(totalprice) as totalprice,
        sum(sp0.order_num) as order_num,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            partition_date as dt,
            sellchannel,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(setnumber*salesplan_count) as ticket_num,
            sum(grossprofit) as grossprofit
        $spo
        group by
            1,2
        ) as sp0
        join (
            $md
                and key_name='sellchannel'
                and key1='1'
            ) as md
        on sp0.sellchannel=md.key
    group by
        1,2
    ) as sp1
    left join (
        select
            fp0.dt,
            md.value2 as pt,
            sum(all_uv) as all_uv,
            sum(fp0.first_uv) as first_uv,
            sum(fp0.detail_uv) as detail_uv,
            sum(fp0.order_uv) as order_uv,
            sum(fp0.list_uv) as list_uv,
            sum(pt_uv) pt_uv
        from (
            select
                partition_date as dt,
                case when 2 in (\$dim) then app_name
                else 'all' end as app_name,
                approx_distinct(union_id) as all_uv,
                approx_distinct(case when page_cat=1 then union_id end) as first_uv,
                approx_distinct(case when page_cat=2 then union_id end) as detail_uv,
                approx_distinct(case when page_cat=3 then union_id end) as order_uv,
                approx_distinct(case when page_name_my='演出列表页' then union_id end) as list_uv
            $mpw
            group by
                1,2
            ) as fp0
            left join (
                $md
                and key_name='app_name'
                ) md
            on fp0.app_name=md.key
            left join (
                select
                    partition_date as dt,
                    '格瓦拉' as pt,
                    approx_distinct(case when page_name_my='平台首页' then union_id end) as pt_uv
                $ort
                where
                    partition_date>='\$\$begindate'
                    and partition_date<'\$\$enddate'
                    and partition_biz_bg=0
                    and app_name='gewara'
                    and 2 in (\$dim)
                group by
                    1,2
                ) as ort
            on ort.pt=md.value2
            and ort.dt=fp0.dt
        group by
            1,2
        ) as fp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
