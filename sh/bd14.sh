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
    mobile
from (
    select 
        mobile,
        row_number() over (order by 1) rank
    from (
        select distinct
            so.mobile
        from (
            select
                usermobileno as mobile
            from
                mart_movie.detail_myshow_saleorder
            where
                sellchannel in (\$sellchannel_id)
                and performance_id in (
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
                            and (
                                province_name in ('\$area_name')
                                or city_name in ('\$area_name')
                                or '全部' in ('\$area_name')
                                )
                            and (
                                performance_id in (\$performance_id)
                                or -99=\$performance_id
                                )
                            and (
                                performance_name like '%\$performance_name%'
                                or '测试'='\$performance_name'
                                )
                        ) c1
                    where
                        performance_id not in (\$no_performance_id)
                    )
            union all
            select 
                order_mobile as mobile
            from
                upload_table.detail_wg_saleorder
            where
                \$order_src=1
                and item_id in (
                    select distinct
                        item_id
                    from (
                        select
                            item_id
                        from
                            upload_table.dim_wg_items
                        where (
                                type_lv1_name in ('\$category_name')
                                or '全部' in ('\$category_name')
                                ) 
                            and (
                                city_name in ('\$area_name')
                                or province_name in ('\$area_name')
                                or '全部' in ('\$area_name')
                                )
                            and (
                                item_no in (\$performance_id)
                                or -99=\$performance_id
                                )
                            and (
                                title_cn like '%\$performance_name%'
                                or '测试'='\$performance_name'
                                )
                        ) as di
                    where
                        item_id not in (\$no_performance_id)
                    ) 
            ) so
            left join upload_table.myshow_mark mm
            on mm.usermobileno=so.mobile
            and \$id=1
        where
            mm.usermobileno is null
        ) as cs
    ) as c
where
    rank<=\$limit
$lim">${attach}

echo "succuess,detail see ${attach}"
