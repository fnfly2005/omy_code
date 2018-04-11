#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mou=`fun dim_myshow_movieuser.sql`
cit=`fun dim_myshow_city.sql`

file="yysc11"
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
            mobile
        from (
            select
                mobile
            from
                mart_movie.dim_myshow_movieuser
            where
                active_date>='\$\$begindate'
                and active_date<'\$\$enddate'
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
            union all
            select
                mobile
            from
                mart_movie.dim_myshow_movieusera
            where
                active_date>='\$\$begindate'
                and active_date<'\$\$enddate'
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
            ) mu
        ) mou
        left join upload_table.myshow_mark mm
        on mm.usermobileno=mou.mobile
        and \$id=1
    where
        mm.usermobileno is null
    ) as c
where
    rank<=\$limit
$lim">${attach}

echo "succuess,detail see ${attach}"
