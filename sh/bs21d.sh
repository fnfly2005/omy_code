#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

oni=`fun detail_maoyan_order_new_info.sql` 
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`
dea=`fun dim_deal_new.sql`
cus=`fun dim_myshow_customer.sql`

file="bs21"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    channel_name,
    title,
    order_num,
    quantity,
    total_money,
    rank
from (
    select
        dt,
        channel_name,
        title,
        order_num,
        quantity,
        total_money,
        row_number() over (partition by dt,channel_name order by total_money desc) rank
    from (
        select
            dt,
            channel_name,
            title,
            count(distinct oni.order_id) order_num,
            sum(quantity) quantity,
            sum(total_money) total_money
        from (
            $oni
            ) oni
            join (
            $cni
            ) cni
            on oni.order_id=cni.order_id
            join (
            $dea
            ) dea
            on cni.deal_id=dea.deal_id
        group by
            1,2,3
            ) as ocd
    ) oc1
where
    rank<=10
$lim">${attach}

echo "succuess,detail see ${attach}"

