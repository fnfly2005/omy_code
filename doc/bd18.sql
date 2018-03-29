
select distinct
    msh.shop_id,
    case when dsh.dp_shop_id is null then shop_name
    else dp_shop_name end as shop_name,
    dsh.dp_shop_first_cate_name,
    dsh.dp_shop_second_cate_name,
    poa.classname,
    poa.typename
from (
    select shop_id, shop_name from mart_movie.dim_myshow_shop
    ) msh
    left join (
    select dp_shop_id, dp_shop_name, mt_main_poi_id, dp_shop_first_cate_name, dp_shop_second_cate_name, dp_shop_third_cate_name, dp_shop_fourth_cate_name from dw.dim_dp_shop
    ) dsh
    on msh.shop_id=dsh.dp_shop_id
    left join (
        select 
            mainpoiid,
            typename,
            classname
        from (
            select typeid, typename, classid, classname from dim.poicategory where classid in (3,1854)
            ) pca
            join (
            select mainpoiid, typeid from dim.poi
            ) poi
            on pca.typeid=poi.typeid
        ) poa
    on poa.mainpoiid=dsh.mt_main_poi_id
;
