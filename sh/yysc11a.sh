#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mou=`fun dim_myshow_movieuser.sql`
cit=`fun dim_myshow_city.sql`
mov=`fun dim_movie.sql`

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
        mobile,
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
                and city_id in (
                    select 
                        mt_city_id
                    from (
                        $cit
                        and province_name in ('\$name')
                        union all
                        $cit
                        and city_name in ('\$name')
                        ) c1
                    )
                and (
                    movie_id in (\$movie_id)
                    or -99 in (\$movie_id)
                    )
            union all
            select
                mobile
            from
                mart_movie.dim_myshow_movieusera
            where
                active_date>=date_add('day',-\$at,current_date)
                and city_id in (
                    select distinct
                        mt_city_id
                    from (
                        $cit
                        and province_name in ('\$name')
                        union all
                        $cit
                        and city_name in ('\$name')
                        ) c1
                    )
                and (
                    movie_id in (\$movie_id)
                    or -99 in (\$movie_id)
                    )
            ) mu
        ) mou
        left join (
        select mobile
        from upload_table.send_fn_user
        where send_date>=date_add('day',-\$id,current_date)
        union all 
        select mobile
        from upload_table.send_wdh_user
        where send_date>=date_add('day',-\$id,current_date)
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
