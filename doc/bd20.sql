
select 
    dp_shop_id,
    dp_shop_name,
    dp_province_name,
    dp_city_name,
    dp_district_name,
    category_name,
    count(distinct performance_id) performance_no,
    count(distinct show_id) show_no,
    avg(ticket_price) as ticket_price
from (
    select
        dp_shop_id,
        dp_shop_name,
        dp_province_name,
        dp_city_name,
        dp_district_name,
        category_name,
        performance_id,
        show_id,
        avg(ticket_price) as ticket_price
    from (
        select shop_id, category_name, show_starttime, performance_id, show_id, ticket_price from mart_movie.dim_myshow_salesplan
        where show_starttime>='$$begindate'
            and show_starttime<'$$enddate'
        ) sal 
        join (
        select dp_shop_id, dp_shop_name, mt_main_poi_id, dp_city_id, dp_city_name, dp_province_id, dp_province_name, dp_district_id, dp_district_name, dp_shop_first_cate_id, dp_shop_first_cate_name, dp_shop_second_cate_id, dp_shop_second_cate_name, dp_shop_address from dw.dim_dp_shop
        where dp_city_name like '上海%'
        and dp_district_name like '徐汇%'
        ) sho
        on sho.dp_shop_id=sal.shop_id
    group by
        1,2,3,4,5,6,7,8
    ) ss
group by
    1,2,3,4,5,6
union all
select 
    dp_shop_id,
    dp_shop_name,
    dp_province_name,
    dp_city_name,
    dp_district_name,
    '全部' as category_name,
    count(distinct performance_id) performance_no,
    count(distinct show_id) show_no,
    avg(ticket_price) as ticket_price
from (
    select
        dp_shop_id,
        dp_shop_name,
        dp_province_name,
        dp_city_name,
        dp_district_name,
        performance_id,
        show_id,
        avg(ticket_price) as ticket_price
    from (
        select shop_id, category_name, show_starttime, performance_id, show_id, ticket_price from mart_movie.dim_myshow_salesplan
        where show_starttime>='$$begindate'
            and show_starttime<'$$enddate'
        ) sal 
        join (
        select dp_shop_id, dp_shop_name, mt_main_poi_id, dp_city_id, dp_city_name, dp_province_id, dp_province_name, dp_district_id, dp_district_name, dp_shop_first_cate_id, dp_shop_first_cate_name, dp_shop_second_cate_id, dp_shop_second_cate_name, dp_shop_address from dw.dim_dp_shop
        where dp_city_name like '上海%'
        and dp_district_name like '徐汇%'
        ) sho
        on sho.dp_shop_id=sal.shop_id
    group by
        1,2,3,4,5,6,7
    ) ss
group by
    1,2,3,4,5
;
