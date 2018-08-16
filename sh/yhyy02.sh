#!/bin/bash
source ./fuc.sh

nbc=`fun dim_myshow_nearbycity.sql`
cit=`fun dim_myshow_city.sql u`

file="yy01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    city_name,    
    km_num,
    coalesce(mys_num,0) as mys_num,
    coalesce(mov_90_num,0) as mov_90_num,
    coalesce(mov_180_num,0) as mov_180_num,
    coalesce(mov_all_num,0) as mov_all_num
from (
    $nbc
        and dpcity_id in (\$dpcity_id)
        and km_num<=300
    union all
    select
        \$dpcity_id as dpcity_id,
        \$dpcity_id as nearbydpcity_id,
        0 as km_num
    ) as nbc
    join mart_movie.dim_myshow_city dmc
    on dmc.city_id=nbc.nearbydpcity_id
    left join (
        select
            city_id,
            count(distinct mobile) mys_num
        from (
            select
                city_id,
                mobile
            from
                mart_movie.dim_myshow_userlabel
            union all
            select
                city_id,
                mobile
            from
                mart_movie.dim_wg_userlabel
            union all
            select
                city_id,
                mobile
            from
                mart_movie.dim_wp_userlabel
            ) as mww
        group by
            1
        ) as dmu
    on dmu.city_id=nbc.nearbydpcity_id
    left join (
        select
            city_id as mt_city_id,
            approx_distinct(case when active_date>=date_add('day',-90,current_date) then mobile end) as mov_90_num,
            approx_distinct(case when active_date>=date_add('day',-180,current_date) then mobile end) as mov_180_num,
            approx_distinct(mobile) mov_all_num
        from (
            select
                mobile,
                city_id,
                active_date
            from
                mart_movie.dim_myshow_movieuser
            union all
            select
                mobile,
                city_id,
                active_date
            from
                mart_movie.dim_myshow_movieusera
            ) mov
        group by
            1
        ) as dmm
    on dmm.mt_city_id=dmc.mt_city_id
    and dmc.dp_flag=0
where
    dmm.mt_city_id is not null
    or dmu.city_id is not null
order by
    km_num,
    mov_all_num desc
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
