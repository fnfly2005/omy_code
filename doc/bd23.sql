
select distinct
    user_id
from (
    select
        user_id,
        category_flag
    from mart_movie.dim_myshow_userlabel where 1=1
        and city_id in (
            select
                city_id
            from mart_movie.dim_myshow_city where 1=1
                and ((province_id in ($province_id) and 1=$pro)
                    or (city_id in ($city_id) and 2=$pro)
                    or 0=$pro)
            )
        and sellchannel in ($sellchannel)
    ) as bel
    CROSS JOIN UNNEST(category_flag) as t (category_id)
where
    category_id in ($category_id)
    or -99 in ($category_id)
;
