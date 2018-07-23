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

spo=`fun detail_myshow_saleorder.sql`
md=`fun myshow_dictionary.sql`
ssp=`fun dim_myshow_salesplan.sql`
sor=`fun dp_myshow__s_orderrefund.sql`


file="bd09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    ht,
    mit,
    case when 2 in (\$dim) then md.value2
    else 'all' end as pt,
    case when 3 in (\$dim) then customer_type_name
    else 'all' end as customer_type_name,
    case when 3 in (\$dim) then customer_lvl1_name
    else 'all' end as customer_lvl1_name,
    area_1_level_name,
    area_2_level_name,
    province_name,
    city_name,
    category_name,
    shop_name,
    performance_id,
    performance_name,
    case when 4 in (\$dim) then show_name
    else 'all' end as show_name,
    case when 6 in (\$dim) then ticket_price
    else 'all' end as ticket_price,
    case when 6 in (\$dim) then salesplan_name
    else 'all' end as salesplan_name,
    case when 5 in (\$dim) then refund_flag
    else 'all' end as refund_flag,
    count(distinct meituan_userid) as user_num,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num,
    sum(TotalPrice) as TotalPrice
from (
    select
        case when 1 in (\$dim) then spo.dt
        else 'all' end as dt,
        case when 7 in (\$dim) then ht
        else 'all' end as ht,
        case when 8 in (\$dim) then (cast(substr(pay_time,15,1) as bigint)+1)*10
        else 'all' end as mit,
        spo.sellchannel,
        spo.salesplan_id,
        spo.meituan_userid,
        case when sor.order_id is null then 'no'
            when sor.issuc=0 then 'apply'
        else 'yes' end as refund_flag,
        count(distinct spo.order_id) as order_num,
        sum(ticket_num) as ticket_num,
        sum(spo.TotalPrice) as TotalPrice
    from (
        $spo
            and sellchannel in (\$sellchannel)
            and (performance_id in (\$id)
                or -99 in (\$id))
        ) spo
        left join (
            $sor
            ) sor
        on sor.order_id=spo.order_id
    where (
        8 not in (\$dim)
        and 7 not in (\$dim)
            )
        or (ht>=\$hts
            and ht<\$hte
                )
    group by
        1,2,3,4,5,6,7
    union all
    select
        case when 1 in (\$dim) then substr(pay_time,1,10)
        else 'all' end as dt,
        case when 7 in (\$dim) then substr(pay_time,12,2)
        else 'all' end as ht,
        case when 8 in (\$dim) then (cast(substr(pay_time,15,1) as bigint)+1)*10
        else 'all' end as mit,
        sellchannel,
        salesplan_id,
        meituan_userid,
        'all' refund_flag,
        count(distinct order_id) as order_num,
        sum(salesplan_count*setnumber) as ticket_num,
        sum(TotalPrice) as TotalPrice
    from
        upload_table.detail_myshow_salerealorder
    where
        sellchannel in (\$sellchannel)
        and pay_time is not null
        and pay_time>='\$\$begindate'
        and pay_time<'\$\$enddate'
        and (performance_id in (\$id)
            or -99 in (\$id))
        and \$real=1
        and ((8 not in (\$dim)
        and 7 not in (\$dim)
            )
        or (substr(pay_time,12,2)>=\$hts
            and substr(pay_time,12,2)<\$hte
                ))
    group by
        1,2,3,4,5,6,7
        ) as spo
    join (
        $ssp
        and (customer_name like '%\$customer_name%'
        or '全部'='\$customer_name')
        and (customer_code in (\$customer_code)
        or -99 in (\$customer_code))
        and (performance_name like '%\$name%'
        or '全部'='\$name')
        and (performance_id in (\$id)
            or -99 in (\$id))
        and (shop_name like '%\$shop_name%'
        or '全部'='\$shop_name')
        ) ssp
        on spo.salesplan_id=ssp.salesplan_id
    left join (
        $md
        and key_name='sellchannel'
        ) md
        on md.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
