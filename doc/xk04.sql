
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
    mon_GrossProfit,
    ap_num,
    sp_num,
    round(sp_num*1.0/ap_num,4) sp_rate,
    ap_num-sp_num unsp_num,
    round(1-sp_num*1.0/ap_num,4) unsp_rate
from (
    select partition_date as dt, customer_type_id, area_1_level_name, online_performance_num ap_num from mart_movie.topic_myshow_dailyonlinereport where partition_date='$$yesterday'
    and online_performance_num<>0
    and customer_type_id<>1
    ) tdo
    left join (
    select partition_date as dt, customer_type_id, area_1_level_name, performance_num sp_num, round(TotalPrice,0) TotalPrice, round(GrossProfit,0) GrossProfit from mart_movie.topic_myshow_dailyonlinereport where partition_date='$$yesterday'
    and customer_type_id<>1
    ) tds
    on tdo.customer_type_id=tds.customer_type_id
    and tdo.area_1_level_name=tds.area_1_level_name
    left join (
        select 
            customer_type_id,
            area_1_level_name,
            round(sum(TotalPrice),0) mon_TotalPrice,
            round(sum(GrossProfit),0) mon_GrossProfit
        from 
            mart_movie.topic_myshow_dailysalesreport
        where 
            partition_date>='$$monthfirst'
            and customer_type_id<>1
        group by
            1,2
            ) t1
    on tdo.customer_type_id=t1.customer_type_id
    and tdo.area_1_level_name=t1.area_1_level_name
;
