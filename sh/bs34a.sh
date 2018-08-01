#!/bin/bash
path=""
fun() {
    tmp=`cat ${path}sql/${1} | grep -iv "/\*"`
    if [ -n $2 ];then
        if [[ $2 =~ d ]];then
            tmp=`echo $tmp | sed 's/where.*//'`
        fi
        if [[ $2 =~ u ]];then
            tmp=`echo $tmp | sed 's/.*from/from/'`
        fi
        if [[ $2 =~ t ]];then
            tmp=`echo $tmp | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
        fi
        if [[ $2 =~ m ]];then
            tmp=`echo $tmp | sed "s/begindate/monthfirst{-1m}/g;s/enddate/monthfirst/g"`
        fi
    fi
    echo $tmp
}

spo=`fun detail_myshow_salepayorder.sql u`
md=`fun myshow_dictionary.sql`
mdc=`fun myshow_dictionary.sql u`
mpw=`fun detail_myshow_pv_wide_report.sql u`

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
    avg(grossprofit) as grossprofit
from (
    select
        sp0.dt,
        md.value2 as pt,
        sum(totalprice) as totalprice,
        sum(sp0.order_num) as order_num,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            substr(pay_time,1,10) as dt,
            case when 2 in (\$dim) then sellchannel
            else -99 end as sellchannel,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(setnumber*salesplan_count) as ticket_num,
            sum(grossprofit) as grossprofit
        $spo
            and sellchannel not in (9,10,11)
        group by
            1,2
        ) as sp0
        left join (
            $md
            and key_name='sellchannel'
            ) as md
        on sp0.sellchannel=md.key
    group by
        1,2
    ) as sp1
    left join (
        select
            dt,
            md.value2 as pt,
            sum(all_uv) as all_uv,
            sum(fp0.first_uv) as first_uv,
            sum(fp0.detail_uv) as detail_uv,
            sum(fp0.order_uv) as order_uv
        from (
            select
                partition_date as dt,
                app_name,
                approx_distinct(union_id) as all_uv,
                approx_distinct(case when page_cat=1 then union_id end) as first_uv,
                approx_distinct(case when page_cat=2 then union_id end) as detail_uv,
                approx_distinct(case when page_cat=3 then union_id end) as order_uv
            $mpw
            group by
                1,2
            ) as fp0
            left join (
                $md
                and key_name='app_name'
                ) md
            on fp0.app_name=md.key
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
