#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
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

fpw=`fun detail_flow_pv_wide_report.sql u`
fmw=`fun detail_flow_mv_wide_report.sql u`
spo=`fun detail_myshow_salepayorder.sql`

file="yysc13"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    fp1.dt,
    fp1.uv_source,
    all_uv,
    detail_uv,
    order_num,
    ticket_num,
    totalprice,
    grossprofit
from (
    select
        dt,
        uv_source,
        approx_distinct(union_id) as all_uv,
        approx_distinct(
            case when page_identifier in (
                'c_Q7wY4',
                'packages/show/pages/detail/index',
                'pages/show/detail/index'
                ) then union_id end) as detail_uv
    from (
        select
            partition_date as dt,
            case when page_identifier in ('c_Q7wY4','c_oEWlZ') then custom['fromTag']
            else utm_source end as uv_source,
            page_identifier,
            union_id
        $fpw
        and page_identifier in (
            'c_Q7wY4',
            'c_oEWlZ',
            'pages/show/detail/index',
            'packages/show/pages/detail/index',
            'pages/show/index/index',
            'packages/show/pages/index/index'
            )
        ) fpw
    where
        uv_source is not null
        and uv_source<>'0'
        and (uv_source in ('\$sou')
            or 'all' in ('\$sou')
            )
    group by
        1,2
    ) fp1
    left join (
        select
            fmw.dt,
            uv_source,
            count(distinct fmw.order_id) order_num,
            sum(ticket_num) as ticket_num,
            sum(totalprice) as totalprice,
            sum(grossprofit) as grossprofit
        from (
            select distinct
                partition_date as dt,
                case when event_id in ('b_XZfmh','b_WLx9n') 
                    then custom['fromTag']
                else utm_source end as uv_source,
                order_id
            $fmw
            and event_id in (
                'b_XZfmh',
                'b_WLx9n',
                'b_w047f3uw'
                ) 
            ) fmw
            join (
                $spo
                and sellchannel not in (9,10,11)
                ) spo
            on spo.order_id=fmw.order_id
            and spo.dt=fmw.dt
            and uv_source is not null
            and uv_source<>'0'
            and (uv_source in ('\$sou')
                or 'all' in ('\$sou')
                )
        group by
            1,2
        ) as sp1
        on fp1.dt=sp1.dt
        and fp1.uv_source=sp1.uv_source
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
