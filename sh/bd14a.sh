#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}
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
                            and (
                                shop_name like '%\$shop_name%'
                                or '测试'='\$shop_name'
                                )
                        ) c1
                    where performance_id not in (\$no_performance_id)
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
                            upload_table.dim_wg_item
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
                            and (
                                venue_name like '%\$shop_name%'
                                or '测试'='\$shop_name'
                                )
                        ) as di
                    where item_id not in (\$no_performance_id)
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
                        send_date>=current_date
                        and \$id<>0
                            )
                    union all 
                    select mobile
                    from upload_table.send_wdh_user
                    where (
                        send_date>=current_date
                        and \$id<>0
                            )
                    ) m1
                ) mm
            on mm.mobile=mou.mobile
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
