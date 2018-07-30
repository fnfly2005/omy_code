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
        row_number() over (order by 1 desc) rank
    from (
        select
            so.mobile
        from (
            select distinct
                mobile
            from (
                select 
                    mobile,
                    performance_flag,
                    usertype
                from (
                    select
                        mobile,
                        action_flag,
                        performance_flag,
                        usertype
                    from (
                        select 
                            mobile,
                            category_flag,
                            action_flag,
                            performance_flag,
                            1 as usertype
                        from
                            mart_movie.dim_myshow_userlabel
                        where
                            1 in (\$order_src)
                            and (active_date>=date_add('month',-\$mth_id,date_parse('\$\$enddate','%Y-%m-%d'))
                                or \$mth_id=0
                                )
                            and sellchannel in (\$sellchannel_id)
                            and (
                                (
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
                            and (
                                pay_num>\$pay_num
                                or \$pay_num=-99
                                )
                            and (
                                pay_money>\$pay_money
                                or \$pay_money=-99
                                )
                        union all
                        select 
                            mobile,
                            category_flag,
                            action_flag,
                            item_flag as performance_flag,
                            2 as usertype
                        from
                            mart_movie.dim_wg_userlabel
                        where
                            2 in (\$order_src)
                            and (active_date>=date_add('month',-\$mth_id,date_parse('\$\$enddate','%Y-%m-%d'))
                                or \$mth_id=0
                                )
                            and (
                                (
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
                            and (
                                pay_num>\$pay_num
                                or \$pay_num=-99
                                )
                            and (
                                pay_money>\$pay_money
                                or \$pay_money=-99
                                )
                        union all
                        select 
                            mobile,
                            category_flag,
                            action_flag,
                            item_flag as performance_flag,
                            3 as usertype
                        from
                            mart_movie.dim_wp_userlabel
                        where
                            3 in (\$order_src)
                            and (active_date>=date_add('month',-\$mth_id,date_parse('\$\$enddate','%Y-%m-%d'))
                                or \$mth_id=0
                                )
                            and (
                                (
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
                            and (
                                pay_num>\$pay_num
                                or \$pay_num=-99
                                )
                            and (
                                pay_money>\$pay_money
                                or \$pay_money=-99
                                )
                        ) ws
                        cross join unnest(category_flag) as t (category_id)
                    where
                        category_id in (\$category_id)
                        or -99 in (\$category_id)
                    ) sw
                    cross join unnest(action_flag) as t (action_id)
                where
                    action_id in (\$action_id)
                    or -99 in (\$action_id)
                ) sa
                cross join unnest(performance_flag) as t (performance_id)
            where (
                performance_id in (
                    select
                        performance_id
                    from 
                        mart_movie.dim_myshow_performance
                    where (
                            performance_name like '%\$performance_name%'
                            or '测试'='\$performance_name'
                            )
                        and (
                            shop_name like '%\$shop_name%'
                            or '测试'='\$shop_name'
                            )
                    ) 
                and usertype=1
                )
                or (
                    performance_id in (
                        select
                            item_nu
                        from
                            upload_table.dim_wg_performance
                        where (
                                performance_name like '%\$performance_name%'
                                or '测试'='\$performance_name'
                                )
                            and (
                                shop_name like '%\$shop_name%'
                                or '测试'='\$shop_name'
                                )
                        ) 
                    and usertype=2
                    )
                or (
                    performance_id in (
                        select
                            item_no
                        from
                            upload_table.dim_wp_items
                        where (
                                item_name like '%\$performance_name%'
                                or '测试'='\$performance_name'
                                )
                            and (
                                venue_name like '%\$shop_name%'
                                or '测试'='\$shop_name'
                                )
                        )
                    and usertype=3
                    )
                or ('\$performance_name'='测试'
                    and '测试'='\$shop_name')
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
                    union all
                    select
                        usermobileno as mobile
                    from 
                        mart_movie.detail_myshow_saleorder
                    where
                        pay_time is not null
                        and performance_id in (\$fit_pid)
                    union all
                    select
                        phonenumber as mobile
                    from
                        origindb.dp_myshow__s_messagepush
                    where
                        performanceid in (\$fit_pid)
                    union all
                    select
                        mobile
                    from
                        upload_table.black_list_fn
                    where
                        \$fit_flag=1
                    union all
                    select
                        mobile
                    from
                        upload_table.wdh_upload
                    where
                        \$fit_flag=2
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
