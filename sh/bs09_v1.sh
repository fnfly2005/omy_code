#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
dss=`fun detail_myshow_salesplan.sql`
amp=`fun aggr_myshow_pv_platform.sql`
dp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`
md=`fun my_dictionary.sql`

file="bs09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp.partition_date,
    sp.customer_type_name,
    sp.order_num,
    sp.totalprice,
    sp.sp_num,
    ap.ap_num
from
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    order_num,
    totalprice,
    sp_num
from
(select
    partition_date,
    customer_type_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct spo.performance_id) as sp_num
from
    (
    $spo
    ) as spo
    left join
    (
    $dp
    ) as dp
    on dp.performance_id=spo.performance_id
    left join
    (
    $dc
    ) as dc
    on dc.customer_id=spo.customer_id
group by
    partition_date,
    customer_type_name
grouping sets(
partition_date,
(partition_date,customer_type_name)
)) as t1 ) as sp
left join
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    ap_num
from
    (
    select
        partition_date,
        customer_type_name,
        count(distinct dss.performance_id) as ap_num
    from
       (
       $dss
       and salesplan_sellout_flag=0
       ) as dss
       left join 
       (
       $dc
       ) as dc
       on dss.customer_id=dc.customer_id
    group by
        partition_date,
        customer_type_name
    grouping sets(
    partition_date,
    (partition_date,customer_type_name))
    ) as t2
    ) as ap
    on sp.partition_date=ap.partition_date
    and sp.customer_type_name=ap.customer_type_name
$lim">${attach}

echo "
select
    s1.partition_date,
    s1.value2,
    order_num,
    totalprice,
    uv,
    pv
from
(select
    partition_date,
    value2,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice
from
    (
    $spo
    ) as spo
    left join
    (
    $md
    and key_name='sellchannel'
    ) as md
    on md.key=spo.sellchannel
group by
    1,2) as s1
left join
    (
    $amp
    ) as amp
    on s1.partition_date=amp.partition_date
    and s1.value2=amp.new_app_name
$lim">>${attach}

echo "
select
    partition_date,
    performance_name,
    order_num,
    totalprice,
    rank
from
(select
    partition_date,
    performance_name,
    order_num,
    totalprice,
    row_number() over (partition by partition_date order by totalprice desc) as rank 
from
(select
    partition_date,
    performance_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice
from
    (
    $spo
    ) as spo
    left join
    (
    $dp
    ) as dp
    on dp.performance_id=spo.performance_id
group by
    1,2
    ) as s1) as s2
where
    rank<=10
$lim">>${attach}
echo "succuess,detail see ${attach}"

