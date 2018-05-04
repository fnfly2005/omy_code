
select
    case when 1 in ($dim) then substr(pay_time,1,10) 
    else 'all' end as dt,
    case when 2 in ($dim) then province_name
    else 'all' end as province_name,
    case when 3 in ($dim) then city_name
    else 'all' end as city_name,
    count(distinct order_id) order_num
from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
    and fetch_type=2
    and performance_id in ($performance_id)
group by
    1,2,3
;
