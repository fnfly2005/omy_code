#!/bin/bash
source ./fuc.sh

spe=`fun myshow_send_performance.sql`

file="bd14"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    mobile,
    \$send_performance_id as send_performance_id,
    '\$\$enddate' as send_date,
    cast(floor(rand()*\$batch_code) as bigint)+1 as batch_code,
    '\$sendtag' as sendtag
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
                performance_id in (
                    select distinct
                        performance_id
                    from
                        mart_movie.dim_myshow_performance
                    where (
                            regexp_like(performance_name,'\$performance_name')
                            or '测试'='\$performance_name'
                            )
                        and (
                            performance_id in (\$performance_id)
                            or -99 in (\$performance_id)
                            )
                        and (
                            shop_id in (\$shop_id)
                            or -99 in (\$shop_id)
                            )
                        and (
                            regexp_like(shop_name,'\$shop_name')
                            or '测试'='\$shop_name'
                            )
                        and ((
                                city_id in (\$city_id)
                                and 1 in (\$cp)
                                )
                            or (
                                city_id in (
                                    select
                                        city_id
                                    from
                                        mart_movie.dim_myshow_city
                                    where
                                        province_id in (\$province_id)
                                    )
                                and 2 in (\$cp)
                                )
                            or 3 in (\$cp)
                            )
                        and performance_id not in (\$no_performance_id)
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
                    from
                        upload_table.dim_wg_performance it
                        left join upload_table.dim_wg_citymap ci
                        on ci.city_name=it.city_name
                        left join upload_table.dim_wg_type ty
                        on ty.type_lv1_name=it.category_name
                    where (
                            regexp_like(performance_name,'\$performance_name')
                            or '测试'='\$performance_name'
                            )
                        and (
                            regexp_like(shop_name,'\$shop_name')
                            or '测试'='\$shop_name'
                            )
                        and (
                            item_no in (\$performance_id)
                            or -99 in (\$performance_id)
                            )
                        and (
                            (
                                ci.city_id in (\$city_id)
                                and 1 in (\$cp)
                                )
                            or (
                                ci.city_id in (
                                    select
                                        city_id
                                    from
                                        mart_movie.dim_myshow_city
                                    where
                                        province_id in (\$province_id)
                                    )
                                and 2 in (\$cp)
                                )
                            or 3 in (\$cp)
                            )
                        and item_no not in (\$no_performance_id)
                    )
            ) so
            left join (
                select distinct
                    mobile
                from (
                    select 
                        mobile
                    from 
                        mart_movie.detail_myshow_msuser
                    where (
                        (send_date>=date_add('day',-\$id,date_parse('\$\$enddate','%Y-%m-%d'))
                        and \$id<>0)
                        or sendtag in ('\$send_tag')
                            )
                        and sendtag not in (
                            $spe
                            )
                    union all
                    select mobile
                    from upload_table.send_fn_user
                    where (
                        (send_date>=date_add('day',-\$id,date_parse('\$\$enddate','%Y-%m-%d'))
                        and \$id<>0)
                        or sendtag in ('\$send_tag')
                            )
                        and sendtag not in (
                            $spe
                            )
                    union all 
                    select mobile
                    from upload_table.send_wdh_user
                    where (
                        (send_date>=date_add('day',-\$id,date_parse('\$\$enddate','%Y-%m-%d'))
                        and \$id<>0)
                        or sendtag in ('\$send_tag')
                            )
                        and sendtag not in (
                            $spe
                            )
                    ) m1
                ) mm
            on mm.mobile=so.mobile
        where
            mm.mobile is null
        ) as cs
    ) as c
where
    rank<=\$limit
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
