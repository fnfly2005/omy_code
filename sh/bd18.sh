#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dsh=`fun dim_dp_shop.sql` 
msh=`fun dim_myshow_shop.sql`
poi=`fun poi.sql`
pca=`fun poicategory.sql`

file="bd18"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    msh.shop_id,
    case when dsh.dp_shop_id is null then shop_name
    else dp_shop_name end as shop_name,
    city_name,
    province_name,
    area_2_level_name,
    area_1_level_name,
    dsh.dp_shop_first_cate_name,
    dsh.dp_shop_second_cate_name,
    poa.classname,
    poa.typename
from (
    $msh
    ) msh
    left join (
    $dsh
    ) dsh
    on msh.shop_id=dsh.dp_shop_id
    left join (
        select 
            mainpoiid,
            typename,
            classname
        from (
            $pca
            ) pca
            join (
            $poi
            ) poi
            on pca.typeid=poi.typeid
        ) poa
    on poa.mainpoiid=dsh.mt_main_poi_id
$lim">${attach}

echo "succuess,detail see ${attach}"
