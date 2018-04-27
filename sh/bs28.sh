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

spo=`fun detail_myshow_salepayorder.sql u` 
per=`fun dim_myshow_performance.sql`
cus=`fun dim_myshow_customer.sql`
md=`fun myshow_dictionary.sql`
wso=`fun detail_wg_saleorder.sql u`
wi=`fun dim_wg_item.sql`

file="bs28"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 1 in (\$dim) then substr(dt,1,7) 
    else 'all' end mt,
    case when 2 in (\$dim) then dt
    else 'all' end dt,
    'maoyan' as ds,
    case when 3 in (\$dim) then value2
    else 'all' end pt,
    case when 4 in (\$dim) then customer_type_name
    else 'all' end customer_type_name,
    case when 5 in (\$dim) then customer_lvl1_name
    else 'all' end customer_lvl1_name,
    case when 6 in (\$dim) then category_name
    else 'all' end category_name,
    case when 7 in (\$dim) then area_1_level_name
    else 'all' end area_1_level_name,
    case when 8 in (\$dim) then area_2_level_name
    else 'all' end area_2_level_name,
    case when 9 in (\$dim) then province_name
    else 'all' end province_name,
    case when 10 in (\$dim) then city_name
    else 'all' end city_name,
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit
from (
    select
        partition_date as dt,
        sellchannel,
        customer_id,
        performance_id,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice,
        sum(salesplan_count*setnumber) as ticket_num,
        sum(grossprofit) as grossprofit
    $spo
    group by
        1,2,3,4
        ) spo
    left join (
    $per
    ) per
    on spo.performance_id=per.performance_id
    left join (
    $cus
    ) cus
    on cus.customer_id=spo.customer_id
    left join (
    $md
    and key_name='sellchannel'
    ) md1
    on md1.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11
union all
select
    case when 1 in (\$dim) then substr(dt,1,7) 
    else 'all' end mt,
    case when 2 in (\$dim) then dt
    else 'all' end dt,
    'weige' as ds,
    case when 3 in (\$dim) then value2 
    else 'all' end as pt,
    'all' customer_type_name,
    'all' customer_lvl1_name,
    case when 6 in (\$dim) then type_lv1_name
    else 'all' end type_lv1_name,
    'all' area_1_level_name,
    'all' area_2_level_name,
    case when 9 in (\$dim) then province_name
    else 'all' end province_name,
    case when 10 in (\$dim) then city_name
    else 'all' end city_name,
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    0 as ticket_num,
    0 as grossprofit
from (
    select
        dt,
        item_id,
        order_src,
        count(distinct order_id) as order_num,
        sum(total_money) as totalprice
    $wso
    and order_src<>10
    and (length(pay_no)>4
    or \$pay=0)
    group by
        1,2,3
        ) wso
    left join (
    $wi
    ) wi
    on wso.item_id=wi.item_id
    left join (
    $md
    and key_name='order_src'
    ) md2
    on wso.order_src=md2.key
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
