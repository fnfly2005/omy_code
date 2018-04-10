#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}
ii=`fut item_info.sql`
rsf=`fut report_sales_from.sql`
tic=`fut order_ticket.sql`

item="('1712073160')"

file="wp_bd03"
lim=";"
attach="${path}doc/${file}.sql"
echo "
select
    dt,
    x_from,
    price_name,
    sum(pay_money) as pay_money,
    sum(sku_num) as sku_num
from (
    $rsf
    and item_id in (
        select id
        from item_info
        where item_no in $item
        )
    ) rsf
    join (
        select
            price_id,
            price_name,
            order_id,
            count(1) sku_num
        from
            order_ticket
        where item_id in (
            select id
            from item_info
            where item_no in $item
            )
        group by
            1,2,3
        ) tic
    on tic.order_id=rsf.order_id
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"
