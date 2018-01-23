#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ds=`fun dim_myshow_show.sql`
spo=`fun detail_myshow_salepayorder.sql` 
ss=`fun detail_myshow_salesplan.sql`
amp=`fun aggr_myshow_pv_platform.sql`
dp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`
md=`fun myshow_dictionary.sql`
dmp=`fun detail_myshow_performance_performancesnapshotid.sql`
apa=`fun aggr_myshow_pv_all.sql`
app=`fun aggr_myshow_pv_page.sql`

file="bs09"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    sp.partition_date,
    sp.customer_type_name,
    sp.category_name,
    sp.area_1_level_name,
    sp.province_name,
    sp.order_num,
    sp.totalprice,
    sp.sp_num,
    ap.ap_num
from
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    order_num,
    totalprice,
    sp_num
from
(select
    partition_date,
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name,
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
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name
grouping sets(
partition_date,
(partition_date,dc.customer_type_name),
(partition_date,dp.category_name),
(partition_date,dp.area_1_level_name),
(partition_date,dp.province_name)
)) as t1 ) as sp
left join
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    ap_num
from
    (
    select
        partition_date,
        dc.customer_type_name,
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name,
        count(distinct ss.performance_id) as ap_num
    from
       (
       $ss
       and salesplan_sellout_flag=0
       ) as ss
       left join
       (
       $dp
       ) as dp
       on dp.performance_id=ss.performance_id
       left join 
       (
       $dc
       ) as dc
       on ss.customer_id=dc.customer_id
    group by
        partition_date,
        dc.customer_type_name,
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name
    grouping sets(
    partition_date,
    (partition_date,dc.customer_type_name),
    (partition_date,dp.category_name),
    (partition_date,dp.area_1_level_name),
    (partition_date,dp.province_name)
    )
    ) as t2
    ) as ap
    on sp.partition_date=ap.partition_date
    and sp.customer_type_name=ap.customer_type_name
    and sp.category_name=ap.category_name
    and sp.area_1_level_name=ap.area_1_level_name
    and sp.province_name=ap.province_name
$lim">${attach}

echo "select
    s1.partition_date,
    s1.value2,
    order_num,
    totalprice,
    sp_num,
    uv,
    pv
from
(select
    partition_date,
    value2,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct performance_id) as sp_num
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

echo "select
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
    rank<=50
$lim">>${attach}

echo "select
    s1.partition_date,
    s1.a_7num,
    s1.a_15num,
    s1.a_30num,
    s2.s_7num,
    s2.s_15num,
    s2.s_30num
from
    (select
        partition_date,
        count(distinct case when (date_diff('day',dt,date_parse(et,'%Y-%m-%d'))-1)<=7 then performance_id end) a_7num,
        count(distinct case when (date_diff('day',dt,date_parse(et,'%Y-%m-%d'))-1)<=15 then performance_id end) a_15num,
        count(distinct case when (date_diff('day',dt,date_parse(et,'%Y-%m-%d'))-1)<=30 then performance_id end) a_30num
    from
    (select
        ss.partition_date,
        date_parse(ss.partition_date,'%Y-%m-%d') as dt,
        ss.performance_id,
        ss.show_id,
        max(substr(ds.show_endtime,1,10)) as et
    from
        (
        $ss
        and salesplan_sellout_flag=0
        ) as ss
        join
        (
        $ds
        ) as ds
        using(show_id)
    group by
        1,2,3,4) as s01
    where 
        date_diff('day',dt,date_parse(et,'%Y-%m-%d'))>0
    group by
        1) as s1
    left join
    (select
        partition_date,
        count(distinct case when date_diff('day',dt,date_parse(et,'%Y-%m-%d'))<=7 then performance_id end) s_7num,
        count(distinct case when date_diff('day',dt,date_parse(et,'%Y-%m-%d'))<=15 then performance_id end) s_15num,
        count(distinct case when date_diff('day',dt,date_parse(et,'%Y-%m-%d'))<=30 then performance_id end) s_30num
    from
    (select
        spo.partition_date,
        date_parse(spo.partition_date,'%Y-%m-%d') as dt,
        spo.performance_id,
        spo.show_id,
        max(substr(ds.show_endtime,1,10)) as et
    from
        (
        $spo
        ) as spo
        join
        (
        $ds
        ) as ds
       using(show_id)
    group by
        1,2,3,4) as s02
    group by
        1) as s2
    on s1.partition_date=s2.partition_date
$lim">>${attach}

echo "select
    sp.partition_date,
    sp.customer_type_name,
    sp.category_name,
    sp.area_1_level_name,
    sp.province_name,
    sp.order_num,
    sp.totalprice,
    sp.sp_num,
    ap.ap_num
from
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    order_num,
    totalprice,
    sp_num
from
(select
    partition_date,
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name,
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
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name
grouping sets(
partition_date,
(partition_date,dc.customer_type_name),
(partition_date,dp.category_name),
(partition_date,dp.area_1_level_name),
(partition_date,dp.province_name)
)) as t1 ) as sp
left join
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    ap_num
from
    (
    select
        partition_date,
        '全部' as customer_type_name,
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name,
        count(distinct dmp.performance_id) as ap_num
    from
       (
       $dmp
       ) as dmp
       left join
       (
       $dp
       ) as dp
       on dp.performance_id=dmp.performance_id
    group by
        partition_date,
        '全部',
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name
    grouping sets(
    partition_date,
    (partition_date,'全部'),
    (partition_date,dp.category_name),
    (partition_date,dp.area_1_level_name),
    (partition_date,dp.province_name)
    )
    ) as t2
    ) as ap
    on sp.partition_date=ap.partition_date
    and sp.customer_type_name=ap.customer_type_name
    and sp.category_name=ap.category_name
    and sp.area_1_level_name=ap.area_1_level_name
    and sp.province_name=ap.province_name
$lim">>${attach}

echo "
select
    partition_date,
    '微信钱包' as plat,
    new_page_name,
    sum(uv) as uv
from
    (
    $apa
    and new_page_name in ('演出首页','演出详情页','演出确认订单页')
    ) apa
group by
    1,2,3
union all
select
    partition_date,
    '全部' as plat,
    new_page_name,
    sum(uv) as uv
from
    (
    $app
    and new_page_name in ('演出首页','演出详情页','演出确认订单页')
    ) app
group by
    1,2,3
$lim">>${attach}

echo "succuess,detail see ${attach}"
