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
select
    count(distinct dsh.mt_main_poi_id) as poi_num,
    count(distinct case when poa.mainpoiid is not null 
        then dsh.mt_main_poi_id end) as xy_poi_num
from (
    $msh
    ) msh
    left join (
    $dsh
    ) dsh
    on msh.shop_id=dsh.dp_shop_id
    left join (
        select 
            mainpoiid
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
