
select
    count(distinct dsh.mt_main_poi_id) as poi_num,
    count(distinct case when poa.mainpoiid is not null 
        then dsh.mt_main_poi_id end) as xy_poi_num
from (
    select shop_id from mart_movie.dim_myshow_shop
    ) msh
    left join (
    select dp_shop_id, mt_main_poi_id from dw.dim_dp_shop
    ) dsh
    on msh.shop_id=dsh.dp_shop_id
    left join (
        select 
            mainpoiid
        from (
            select typeid from dim.poicategory where classid=3
            ) pca
            join (
            select mainpoiid, typeid from dim.poi
            ) poi
            on pca.typeid=poi.typeid
        ) poa
    on poa.mainpoiid=dsh.mt_main_poi_id
;
