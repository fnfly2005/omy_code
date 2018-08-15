#!/bin/bash
source ./fuc.sh
spo=`fun detail_myshow_saleorder.sql`
md=`fun myshow_dictionary.sql`
ssp=`fun dim_myshow_salesplan.sql`
sor=`fun dp_myshow__s_orderrefund.sql`
mss=`fun detail_myshow_salesplan.sql u`


file="bd09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    spo.dt,
    ht,
    mit,
    md.value2 as pt,
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
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num,
    sum(TotalPrice) as TotalPrice,
    sum(current_amount) as current_amount,
    sum(amount_gmv) as amount_gmv
from (
    select
        case when 1 in (\$dim) then spo.dt
        else 'all' end as dt,
        case when 7 in (\$dim) then ht
        else 'all' end as ht,
        case when 8 in (\$dim) then (cast(substr(pay_time,15,1) as bigint)+1)*10
        else 'all' end as mit,
        case when 2 in (\$dim) then spo.sellchannel
        else -99 end as sellchannel,
        spo.salesplan_id,
        case when sor.order_id is null then 'no'
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
        1,2,3,4,5,6
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
        1,2,3,4,5,6
        ) as spo
    join (
        $ssp
        and (regexp_like(customer_name,'\$customer_name')
        or '全部'='\$customer_name')
        and (customer_code in (\$customer_code)
        or -99 in (\$customer_code))
        and (regexp_like(performance_name,'\$name')
        or '全部'='\$name')
        and (performance_id in (\$id)
            or -99 in (\$id))
        and (regexp_like(shop_name,'\$shop_name')
        or '全部'='\$shop_name')
        ) ssp
        on spo.salesplan_id=ssp.salesplan_id
    left join (
        $md
        and key_name='sellchannel'
        ) md
        on md.key=spo.sellchannel
    left join (
        select
            case when 1 in (\$dim) then partition_date
            else 'all' end as dt,
            salesplan_id,
            sum(current_amount) as current_amount,
            sum(sell_price*current_amount) as amount_gmv
        $mss
            and islimited=1
            and salesplan_sellout_flag=0
            and current_amount>=0
            and 2 not in (\$dim)
            and 5 not in (\$dim)
            and 7 not in (\$dim)
            and 8 not in (\$dim)
        group by
            1,2
        ) mss
    on spo.salesplan_id=mss.salesplan_id
    and spo.dt=mss.dt
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
