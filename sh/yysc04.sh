#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

per=`fun dim_myshow_performance.sql` 
fpw=`fun detail_flow_pv_wide_report.sql`
spo=`fun detail_myshow_salepayorder.sql u`
md=`fun myshow_dictionary.sql`

file="yysc04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 1 in (\$dim) then substr(fpw.dt,1,7)
    else 'all' end as mt, 
    case when 2 in (\$dim) then fpw.dt
    else 'all' end as dt, 
    fpw.pt,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    avg(fpw.uv) uv,
    avg(sp1.order_num) order_num,
    avg(sp1.ticket_num) ticket_num,
    avg(sp1.totalprice) totalprice,
    avg(sp1.grossprofit) grossprofit
from (
    select 
        dt,
        value2 as pt,
        performance_id,
        sum(uv) uv
    from (
        select
            partition_date as dt,
            case when 3 in (\$dim) then app_name
            else 'all' end app_name,
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
        ) as fp1
        left join (
        $md
        and key_name='app_name'
        ) md
        on md.key=fp1.app_name
    group by
        1,2,3
    ) as fpw
    left join (
        select
            dt,
            md.value2 as pt,
            performance_id,
            sum(order_num) order_num,
            sum(ticket_num) ticket_num,
            sum(totalprice) totalprice,
            sum(grossprofit) grossprofit
        from (
            select
                partition_date as dt,
                case when 3 in (\$dim) then sellchannel
                else -99 end sellchannel,
                performance_id,
                count(distinct order_id) as order_num,
                sum(salesplan_count*setnumber) as ticket_num,
                sum(totalprice) as totalprice,
                sum(grossprofit) as grossprofit
            $spo
            group by
                1,2,3
            ) as spo
            left join (
            $md
            and key_name='sellchannel'
            ) md
            on md.key=spo.sellchannel
        group by
            1,2,3
        ) sp1
    on sp1.dt=fpw.dt
    and sp1.performance_id=fpw.performance_id
    and sp1.pt=fpw.pt
    left join (
    $per
    ) as per
    on per.performance_id=fpw.performance_id
where
    (sp1.performance_id is not null
    or 0=\$ft)
group by
    1,2,3,4,5,6,7,8,9,10,11
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
