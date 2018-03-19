#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}
ii=`fut item_info.sql`
of=`fut order_form.sql`
rsf=`fut report_sales_flow.sql`
item="('1801158077')"

file="wp_bd02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    passport_user_mobile
from
    (
    $of
    ) of
    join 
    (
    $rsf
    ) rsf
    on of.order_id=rsf.order_id
    join
    (
    $ii
    and item_no in $item
    ) ii
    on rsf.item_id=ii.id
$lim">${attach}

echo "succuess,detail see ${attach}"
