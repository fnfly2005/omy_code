#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mou=`fun dim_myshow_movieuser.sql`
cit=`fun dim_myshow_city.sql`
cin=`fun dim_cinema.sql`
mov=`fun dim_movie.sql`

file="bd23"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    user_id
from (
    select
        user_id,
        row_number() over (order by 1) rank
    from (
        select distinct
            user_id
        from (
            select
                user_id
            from
                mart_movie.aggr_discount_card_seat_dwd
            where
                order_source=1
                and cinema_id in (
                    select distinct
                        cinema_id
                    from (
                        $cit
                        and province_name in ('\$name')
                        union all
                        $cit
                        and city_name in ('\$name')
                        ) c1
                        join (
                        $cin
                        ) cin
                        on cin.city_id=c1.mt_city_id
                        )
                and (
                    movie_id in (\$movie_id)
                    or -99 in (\$movie_id)
                    )
            union all
            select
                user_id
            from
                mart_movie.detail_order_seat_info
            where
                order_source=1
                and cinema_id in (
                    select distinct
                        cinema_id
                    from (
                        $cit
                        and province_name in ('\$name')
                        union all
                        $cit
                        and city_name in ('\$name')
                        ) c1
                        join (
                        $cin
                        ) cin
                        on cin.city_id=c1.mt_city_id
                        )
                and (
                    movie_id in (\$movie_id)
                    or -99 in (\$movie_id)
                    )
            ) mu
        ) mou
    ) as c
where
    rank<=\$limit
$lim">${attach}

echo "succuess,detail see ${attach}"
