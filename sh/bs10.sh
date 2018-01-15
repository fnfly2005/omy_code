#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dp=`fun dim_myshow_performance.sql`
spo=`fun detail_myshow_salepayorder.sql` 
ss=`fun detail_myshow_salesplan.sql`
ds=`fun dim_myshow_show.sql`
file="bs10"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ap.partition_date,
    ap.category_name,
    ap_num,
    sp_num
from
(select
    spo.partition_date,
    dp.category_name,
    count(distinct dp.performance_id) as ap_num
from
    (
    $spo
    ) as spo
    left join 
    (
    $dp
    ) as dp
    on spo.performance_id=dp.performance_id
group by
    1,2) as ap
left join
(select
    spo.partition_date,
    dp.category_name,
    count(distinct dp.performance_id) as sp_num
from
    (
    $spo
    ) as spo
    left join 
    (
    $dp
    ) as dp
    on spo.performance_id=dp.performance_id
group by
    1,2) as sp
on ap.partition_date=sp.partition_date
and ap.category_name=sp.category_name
$lim">${attach}

echo "
select
    ap.partition_date,
    ap.area_1_level_name,
    ap.area_2_level_name,
    ap.province_name,
    ap.city_name,
    ap.ap_num,
    sp.sp_num
from
(select
    ss.partition_date,
    dp.area_1_level_name,
    dp.area_2_level_name,
    dp.province_name,
    dp.city_name,
    count(distinct dp.performance_id) as ap_num
from
    (
    $ss
    ) as ss
    left join 
    (
    $dp
    ) as dp
    on ss.performance_id=dp.performance_id
group by
    1,2,3,4,5) as ap
    left join
(select
    spo.partition_date,
    dp.area_1_level_name,
    dp.area_2_level_name,
    dp.city_name,
    dp.province_name,
    count(distinct dp.performance_id) as sp_num
from
    (
    $spo
    ) as spo
    left join 
    (
    $dp
    ) as dp
    on spo.performance_id=dp.performance_id
group by
    1,2,3,4,5) as sp
    on ap.partition_date=sp.partition_date
    and ap.area_1_level_name=sp.area_1_level_name
    and ap.area_2_level_name=sp.area_2_level_name
    and ap.province_name=sp.province_name
    and ap.city_name=sp.city_name
$lim">>${attach}

echo "
select
    substr(dt,1,10) as dt,
    s1.performance_id,
    s1.show_id,
    date_diff('day',dt,date_parse(et,'%Y-%m-%d')) as dd,
    order_num*1.0/avg_order_num as ao
from
    (select
        performance_id,
        row_number() over (order by order_num desc) as rank
    from
        (select
        performance_id,
        count(distinct order_id) as order_num
    from
        (
        $spo
        ) as sp1
    group by
        1) as sp2) as s0
    join
    (select
        performance_id,
        show_id,
        avg_order_num
    from
    (select
        so2.performance_id,
        so2.show_id,
        avg(so2.order_num) as avg_order_num
    from
    (select
        so1.partition_date,
        so1.performance_id,
        so1.show_id,
        count(distinct so1.order_id) as order_num
    from
        (
        $spo
        ) as so1
    group by
        1,2,3) as so2 
    group by
        1,2) as so3) as s1
    on s0.performance_id=s1.performance_id and s0.rank<=10
    join
    (select
        date_parse(spo.partition_date,'%Y-%m-%d') as dt,
        spo.show_id,
        max(substr(case when show_endtime is not null 
            and length(show_endtime)>0
            and show_starttime<show_endtime 
        then show_endtime
        else show_starttime end,1,10)) as et,
        count(distinct spo.order_id) as order_num
    from
        (
        $spo
        ) as spo
        join
        (
        $ds
        and show_type=1
        ) as ds
       on spo.show_id=ds.show_id
    group by
        1,2) as s2
    on s1.show_id=s2.show_id
$lim">>${attach}

echo "succuess,detail see ${attach}"
