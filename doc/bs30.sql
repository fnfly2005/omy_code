
select 
    $dim,
    count(distinct order_id) order_num
from (
    select
        case when sfo.dianping_userid is not null then 'yes'
        else 'no' end new_flag,
        case when so.fetch_type=2 then so.province_name
        else cit.province_name end province_name,
        case when so.fetch_type=2 then so.city_name
        else cit.city_name end city_name,
        datediff(dt,birthday)/365 age,
        order_id
    from (
        select
            substr(pay_time,1,10) dt,
            province_name,
            city_name,
            fetch_type,
            order_id,
            meituan_userid
        from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and performance_id in ($performance_id)
            ) so
        left join (
        select userid, birthday, city_id from mart_movie.detail_user_base_info where userid is not null and (length(birthday)=10 or city_id<>0)
        ) dub
        on dub.userid=so.meituan_userid
        left join (
        select
            dianping_userid,
            min(first_pay_order_date) first_pay_order_date
        from mart_movie.detail_myshow_salefirstorder where dianping_userid is not null and category_id=-99
        group by
            dianping_userid
        ) sfo
        on sfo.dianping_userid=so.meituan_userid
        and sfo.first_pay_order_date=so.dt
        left join (
        select city_id, mt_city_id, case when mt_city_id=0 then '其他城市' else city_name end as city_name, case when mt_city_id=0 then '其他城市' else province_name end as province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where city_id is not null
        ) cit
        on cit.mt_city_id=dub.city_id
    ) sim
group by
    $dim
;
