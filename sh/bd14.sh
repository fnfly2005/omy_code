#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
per=`fun dim_myshow_performance.sql`

file="bd14"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    usermobileno
from (
    select 
        usermobileno,
        row_number() over (order by 1) rank
    from (
        select distinct
            so.usermobileno
        from (
            select distinct
                performance_id
            from (
                select
                    performance_id
                from
                    mart_movie.dim_myshow_performance
                where (
                    category_name in ('\$category_name')
                    or '全部' in ('\$category_name')
                    )
                    and province_name in ('\$area_name')
                union all
                select
                    performance_id
                from
                    mart_movie.dim_myshow_performance
                where (
                    category_name in ('\$category_name')
                    or '全部' in ('\$category_name')
                    )
                    and city_name in ('\$area_name')
                union all
                select
                    performance_id
                from
                    mart_movie.dim_myshow_performance
                where performance_id in (\$performance_id)
                ) c1
            ) ci
            join (
            select
                usermobileno,
                performance_id
            from
                mart_movie.detail_myshow_saleorder
            where
                performance_id not in (\$no_performance_id)
            ) so
            on so.performance_id=ci.performance_id
            left join upload_table.myshow_mark mm
            on mm.usermobileno=so.usermobileno
            and \$id=1
        where
            mm.usermobileno is null
        ) as cs
    ) as c
where
    rank<=\$limit
$lim">${attach}

echo "succuess,detail see ${attach}"

