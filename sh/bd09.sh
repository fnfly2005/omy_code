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

spo=`fun detail_myshow_salepayorder.sql`
per=`fun dim_myshow_performance.sql`
cus=`fun dim_myshow_customer.sql`
md=`fun myshow_dictionary.sql`
sho=`fun dim_myshow_show.sql`
sfo=`fun detail_myshow_salefirstorder.sql`
sor=`fun dp_myshow__s_orderrefund.sql`

file="bd09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when 1 in (\$dim) then spo.dt
    else 'all' end as dt,
    case when 2 in (\$dim) then md.value2
    else 'all' end as pt,
    case when 3 in (\$dim) then cus.customer_type_name
    else 'all' end as customer_type_name,
    case when 3 in (\$dim) then cus.customer_lvl1_name
    else 'all' end as customer_lvl1_name,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    case when 4 in (\$dim) then show_name
    else 'all' end as show_name,
    case when 5 in (\$dim) then refund_flag
    else 'all' end as refund_flag,
    case when 6 in (\$dim) then newuser_flag
    else 'all' end as newuser_flag,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num,
    sum(TotalPrice) as TotalPrice,
    sum(grossprofit) as grossprofit
from (
    select
        dt,
        sellchannel,
        performance_id,
        customer_id,
        show_id,
        case when sor.order_id is null then 'no'
            when sor.issuc=0 then 'apply'
        else 'yes' end as refund_flag,
        case when sfo.meituan_userid is not null then 'yes'
        else 'no' end as newuser_flag,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.TotalPrice) as TotalPrice,
        sum(spo.grossprofit) as grossprofit
    from (
        $spo
        ) spo
        left join (
        $sfo
        ) sfo
        on sfo.meituan_userid=spo.meituan_userid
        and sfo.first_pay_order_date=spo.dt
        left join (
        $sor
        ) sor
        on sor.order_id=spo.order_id
    group by
        1,2,3,4,5,6,7
        ) as spo
    join (
        $per
        and (performance_name like '%\$name%'
        or '全部'='\$name')
        and (performance_id in (\$id)
            or -99 in (\$id))
        and (shop_name like '%\$shop_name%'
        or '全部'='\$shop_name')
        ) per
        on spo.performance_id=per.performance_id
    join (
        $cus
        and (customer_name like '%\$customer_name%'
        or '全部'='\$customer_name')
        and (customer_code in (\$customer_code)
        or -99 in (\$customer_code))
        ) cus
        on spo.customer_id=cus.customer_id
    left join (
        $sho
        ) sho
        on sho.show_id=spo.show_id
    left join (
        $md
        and key_name='sellchannel'
        ) md
        on md.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
