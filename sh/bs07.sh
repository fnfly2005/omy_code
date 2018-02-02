#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ss=`fun detail_myshow_salesplan.sql`
spo=`fun detail_myshow_salepayorder.sql`
per=`fun dim_myshow_performance.sql` 
cus=`fun dim_myshow_customer.sql`
file="bs07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(partition_date,1,7) as mt,
    sum(setnumber*salesplan_count) as t_num
from
    (
    $spo
    ) as spo
group by
    1
$lim">${attach}

echo "
select
    count(distinct shop_id) as_num,
    count(distinct case when cus.customer_type_id=2 then shop_id end) s_num
from
    (
    $ss
    ) as ss
    left join
    (
    $cus
    ) as cus 
    on cus.customer_id=ss.customer_id
    ">>${attach}

echo "
select 
    substr(x.pay_time,1,7) mt,
    sum(quantity) sq
from mart_movie.detail_maoyan_order_new_info x
join mart_movie.detail_maoyan_order_sale_cost_new_info y
on x.order_id=y.order_id
join mart_movie.dim_deal_new z
on y.deal_id=z.deal_id
WHERE x.pay_time>='2017-10-01'
and x.pay_time<'2017-12-01'
and z.category=12
group by
    1
    ">>${attach}
echo "succuess,detail see ${attach}"
