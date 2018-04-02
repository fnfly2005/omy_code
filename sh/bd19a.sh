#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

file="bd19"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    order_mobile
from (
    select
        order_mobile,
        row_number() over (order by 1) rank
    from (
        select distinct
            order_mobile
        from (
            select distinct
                item_id
            from (
                select
                    item_id
                from
                    upload_table.dim_wg_item
                where (
                        type_lv1_name in ('\$category_name')
                        or '全部' in ('\$category_name')
                        ) 
                    and city_name in ('\$area_name')
                union all
                select
                    item_id
                from
                    upload_table.dim_wg_item
                where (
                        type_lv1_name in ('\$category_name')
                        or '全部' in ('\$category_name')
                        ) 
                    and province_name in ('\$area_name')
                union all
                select
                    item_id
                from
                    upload_table.dim_wg_item
                where
                    item_no in (\$performance_id)
                ) c1
            ) ci
            join (
                select 
                    item_id,
                    order_mobile
                from
                    upload_table.detail_wg_saleorder
                where
                    item_id not in (\$no_performance_id)
                ) so
                on so.item_id=ci.item_id
                left join upload_table.myshow_mark mm
                on mm.usermobileno=so.order_mobile
                and \$id=1
            where
                mm.usermobileno is null
        ) as cs
    ) as c
where
    rank<=\$limit
$lim">${attach}

echo "succuess,detail see ${attach}"

