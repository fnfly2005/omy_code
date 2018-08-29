
select distinct
    minperformance_id,
    ssp.shop_id,
    ssp.shop_name,
    performance_id,
    performance_name
from (
    select
        substr(show_starttime,1,10) as show_startdate,
        shop_id,
        shop_name,
        min(performance_id) as minperformance_id
    from mart_movie.dim_myshow_salesplan where 1=1
        and category_id in (1,2,9)
        and performance_id in ($performance_id)
        and shop_id<>0
    group by
        1,2,3
    ) as ssp
    left join (
        select distinct
            substr(show_starttime,1,10) as show_startdate,
            shop_id,
            performance_id,
            performance_name
        from mart_movie.dim_myshow_salesplan where 1=1
        ) as sps
        on sps.shop_id=ssp.shop_id
        and sps.show_startdate=ssp.show_startdate
where
    minperformance_id<>performance_id
;
