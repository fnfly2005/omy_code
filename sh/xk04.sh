#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

tdo=`fun topic_myshow_dailyonlinereport.sql` 
tds=`fun topic_myshow_dailysalesreport.sql`

file="xk04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    tdo.dt,
    case when tdo.customer_type_id=2   then '自营'
    when tdo.customer_type_id=-99 then '全部'
    else '未知'
    end customer_type,
    tdo.area_1_level_name,
    TotalPrice,
    mon_TotalPrice,
    GrossProfit,
    ap_num,
    sp_num,
    round(sp_num*1.0/ap_num,4) sp_rate,
    ap_num-sp_num unsp_num,
    round(1-sp_num*1.0/ap_num,4) unsp_rate
from (
    $tdo
    and online_performance_num<>0
    and customer_type_id<>1
    ) tdo
    left join (
    $tds
    and customer_type_id<>1
    ) tds
    on tdo.customer_type_id=tds.customer_type_id
    and tdo.area_1_level_name=tds.area_1_level_name
    left join (
        select 
            customer_type_id,
            area_1_level_name,
            round(sum(TotalPrice),0) mon_TotalPrice
        from 
            mart_movie.topic_myshow_dailysalesreport
        where 
            partition_date>='\$\$monthfirst'
            and customer_type_id<>1
        group by
            1,2
            ) t1
    on tdo.customer_type_id=t1.customer_type_id
    and tdo.area_1_level_name=t1.area_1_level_name
$lim">${attach}

echo "succuess,detail see ${attach}"

