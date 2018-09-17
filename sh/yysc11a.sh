#!/bin/bash
#选人工具-电影-短信
source ./fuc.sh

spe=`fun myshow_send_performance.sql`
mou=`fun dim_myshow_movieuser.sql`
cit=`fun dim_myshow_city.sql`
mov=`fun dim_movie.sql`
hly=`fun sql/detail_movie_seat_info_monthly.sql u`
dwd=`fun sql/aggr_discount_card_seat_dwd.sql u`

file="yysc11"
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
        mou.mobile,
        row_number() over (order by 1) rank
    from (
        select distinct
            mobile
        from (
            select
                mobile
            from
                mart_movie.dim_myshow_movieuser
            where
                active_date>=date_add('day',-\$at,current_date)
                and (
                    (
                        city_id in (\$city_id)
                        and 1 in (\$cp)
                        )
                    or (
                        city_id in (
                            select
                                mt_city_id
                            from
                                mart_movie.dim_myshow_city
                            where
                                province_id in (\$province_id)
                            )
                        and 2 in (\$cp)
                        )
                    )
                and (
                    movie_id in (\$movie_id)
                    or -99 in (\$movie_id)
                    )
                and 1 in (\$dim)
            union all
            select
                mobile
            from
                mart_movie.dim_myshow_movieusera
            where
                active_date>=date_add('day',-\$at,current_date)
                and (
                    (
                        city_id in (\$city_id)
                        and 1 in (\$cp)
                        )
                    or (
                        city_id in (
                            select
                                mt_city_id
                            from
                                mart_movie.dim_myshow_city
                            where
                                province_id in (\$province_id)
                            )
                        and 2 in (\$cp)
                        )
                    )
                and (
                    movie_id in (\$movie_id)
                    or -99 in (\$movie_id)
                    )
                and 1 in (\$dim)
            union all
            select
                cast(mobile as bigint) mobile
            from
                upload_table.fn_uploadmobile_data
            where
                2 in (\$dim)
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            union all
            select
                cast(mobile as bigint) mobile
            from
                upload_table.wdh_uploadmobile_data
            where
                3 in (\$dim)
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            union all
            select
                mobile_phone as mobile
            $hly
                and 4 in (\$dim)
                and movie_id in (\$movie_id)
                and ((
                        cinema_city in (\$city_id)
                        and 1 in (\$cp)
                        )
                    or (
                        cinema_city in (
                            select
                                mt_city_id
                            from
                                mart_movie.dim_myshow_city
                            where
                                province_id in (\$province_id)
                            )
                        and 2 in (\$cp)
                        ))
            union all
            select
                mobile_phone as mobile
            $dwd
                and 4 in (\$dim)
                and movie_id in (\$movie_id)
                and ((
                        cinema_city in (\$city_id)
                        and 1 in (\$cp)
                        )
                    or (
                        cinema_city in (
                            select
                                mt_city_id
                            from
                                mart_movie.dim_myshow_city
                            where
                                province_id in (\$province_id)
                            )
                        and 2 in (\$cp)
                        ))
            ) mu
        ) mou
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
                    or sendtag in ('\$send_tag')
                union all 
                select mobile
                from upload_table.send_wdh_user
                where (
                    send_date>=current_date
                    and \$id<>0
                        )
                    or sendtag in ('\$send_tag')
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
        on mm.mobile=mou.mobile
    where
        mm.mobile is null
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
