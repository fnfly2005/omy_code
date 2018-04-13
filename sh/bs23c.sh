#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ite=`fun dim_wg_item.sql` 
cit=`fun dim_myshow_city.sql` 
cat=`fun dim_myshow_category.sql` 
file="bs23"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ite.*,
    cim.city_id dp_city_id,
    cyp.category_id
from upload_table.dim_wg_item ite
    left join upload_table.dim_wg_citymap cim
    on ite.city_name=cim.city_name
    left join upload_table.dim_wg_type cyp
    on ite.type_lv1_name=cyp.type_lv1_name
$lim">${attach}

echo "succuess,detail see ${attach}"

