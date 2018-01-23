
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
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
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
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
    ) as dp
    on spo.performance_id=dp.performance_id
group by
    1,2) as sp
on ap.partition_date=sp.partition_date
and ap.category_name=sp.category_name
;

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
    select partition_date, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
    ) as ss
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
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
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
    ) as dp
    on spo.performance_id=dp.performance_id
group by
    1,2,3,4,5) as sp
    on ap.partition_date=sp.partition_date
    and ap.area_1_level_name=sp.area_1_level_name
    and ap.area_2_level_name=sp.area_2_level_name
    and ap.province_name=sp.province_name
    and ap.city_name=sp.city_name
;

select
    substr(dt,1,10) as dt,
    s1.performance_id,
    s1.show_id,
    date_diff('day',dt,date_parse(et,'%Y-%m-%d')) as date_diff,
    order_num*1.0/avg_order_num as order_num
from
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
        select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
        ) as so1
    group by
        1,2,3) as so2 
    group by
        1,2) as so3) as s1
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
        select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
        ) as spo
        join
        (
        select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
        and show_type=1
        ) as ds
       on spo.show_id=ds.show_id
    group by
        1,2) as s2
    on s1.show_id=s2.show_id
;

select
    s1.date_diff,
    s1.a_num,
    s2.s_num
from
    (select
        date_diff('day',dt,date_parse(et,'%Y-%m-%d')) as date_diff,
        count(distinct show_id) a_num
    from
    (select
        date_parse(ss.partition_date,'%Y-%m-%d') as dt,
        ss.show_id,
        max(substr(case when show_endtime is not null 
            and length(show_endtime)>0
            and show_starttime<show_endtime 
        then show_endtime
        else show_starttime end,1,10)) as et
    from
        (
        select partition_date, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
        and salesplan_sellout_flag=0
        ) as ss
        join
        (
        select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
        ) as ds
        using(show_id)
    group by
        1,2) as s01
    where 
        date_diff('day',dt,date_parse(et,'%Y-%m-%d'))>=0
    group by
        1) as s1
    left join
    (select
        date_diff('day',dt,date_parse(et,'%Y-%m-%d')) as date_diff,
        count(distinct show_id) s_num
    from
    (select
        date_parse(spo.partition_date,'%Y-%m-%d') as dt,
        spo.show_id,
        max(substr(case when show_endtime is not null 
            and length(show_endtime)>0
            and show_starttime<show_endtime 
        then show_endtime
        else show_starttime end,1,10)) as et
    from
        (
        select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
        ) as spo
        join
        (
        select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
        and show_type=1
        ) as ds
       using(show_id)
    group by
        1,2) as s02
    group by
            1) as s2
    using(date_diff)
where 
    date_diff>0
;

select
    value2,
    case when date_diff<=7 then 7
    when date_diff<=15 then 15
    when date_diff<=30 then 30
    else 99 end as flag,
    count(distinct order_id) as o_num
from
(select
    date_diff('day',
    date_parse(spo.partition_date,'%Y-%m-%d'),
    date_parse(substr(ds.show_endtime,1,10),'%Y-%m-%d')
    ) as date_diff,
    md.value2,
    spo.order_id
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    join
    (
    select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
    ) as ds
    on spo.show_id=ds.show_id
    left join
    (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='sellchannel'
    ) as md
    on md.key=spo.sellchannel
    ) as s02
where
    date_diff>=0
group by
    1,2
union all
select
    'all' as value2,
    case when date_diff<=7 then 7
    when date_diff<=15 then 15
    when date_diff<=30 then 30
    else 99 end as flag,
    count(distinct order_id) as o_num
from
(select
    date_diff('day',
    date_parse(spo.partition_date,'%Y-%m-%d'),
    date_parse(substr(ds.show_endtime,1,10),'%Y-%m-%d')
    ) as date_diff,
    md.value2,
    spo.order_id
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    join
    (
    select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
    ) as ds
    on spo.show_id=ds.show_id
    left join
    (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='sellchannel'
    ) as md
    on md.key=spo.sellchannel
    ) as s02
where
    date_diff>=0
group by
    1,2
;
