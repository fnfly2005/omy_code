
select
    substr(dea.createtime,1,7) as mt,
    dp_city_name,
    dp_shop_name,
    count(distinct deal_id) as dea_num
from (
    select dealid as deal_id, cityid as city_id, shopid as shop_id, createtime from origindb.dp_myshow__s_deal
    where
        createtime>='$$begindate'
        and createtime<'$$enddate'
    ) dea
    left join (
    select dp_shop_id, dp_shop_name, mt_main_poi_id, dp_city_id, dp_city_name, dp_province_id, dp_province_name, dp_district_id, dp_district_name, dp_shop_first_cate_id, dp_shop_first_cate_name, dp_shop_second_cate_id, dp_shop_second_cate_name, dp_shop_address from dw.dim_dp_shop
    ) dsh 
    on dsh.dp_shop_id=dea.shop_id
group by
    1,2,3
;
