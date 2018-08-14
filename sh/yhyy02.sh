#!/bin/bash
source ./fuc.sh

snb=`fun dp_myshow__s_nearbycitylist_p.sql`
cit=`fun dim_myshow_city.sql u`

file="yy01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    city_name,    
    dis_tag,
    mys_num,
    mov_90_num,
    mov_180_num,
    mov_all_num
from (
    $snb
        and cityid in (\$city_id)
    union all
    select
        \$city_id as dp_city_id,
        \$city_id as ner_city_id,
        100 as dis_tag
    ) as snb
    join mart_movie.dim_myshow_city dmc
    on dmc.city_id=snb.ner_city_id
    left join (
        select
            city_id,
            count(distinct mobile) mys_num
        from (
            select
                city_id,
                mobile,
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
            ) as 
        group by
            1
        ) as dmu
    on dmu.city_id=snb.ner_city_id
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
order by
    dis_tag,
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
