#!/bin/bash
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

spo=`fun detail_myshow_salepayorder.sql` 
md=`fun myshow_dictionary.sql`
mp=`fun myshow_pv.sql`
mck=`fun topic_movie_deal_kpi_daily.sql`

file="xk02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    partition_date as dt,
    '平台页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=0
        )
group by
    1,2
union all                
select
    partition_date as dt,
    '演出频道页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=1
        )
group by
    1,2
union all                
select
    partition_date as dt,
    '演出详情页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=2
        )
group by
    1,2
union all                
select
    partition_date as dt,
    '确认订单页' type,
    count(distinct union_id) uv
from
    mart_flow.detail_flow_pv_wide_report
where partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and partition_log_channel='movie'
    and partition_app='other_app'
    and app_name='gewara'
    and page_identifier in (
        select 
            value
        from 
            upload_table.myshow_pv
        where key='page_identifier'
            and page='native'
            and page_tag1>-2
            and nav_flag=4
        )
group by
    1,2
union all
select
    spo.dt,
    '订单' as type,
    count(distinct spo.order_id) as uv
from (
    $spo
    and sellchannel=8
    ) spo
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
