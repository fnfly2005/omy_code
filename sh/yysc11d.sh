#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ci=`fun dim_myshow_city.sql` 
file="yysc11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    movie_id as id,
    name
from 
    movie_mis.dim_movie_movie
where 
    movie_type=0
    and releatime>=date_add(current_date,INTERVAL -12 month)
    and movie_wish_num>5000
order by 
    movie_wish_num desc
$lim">${attach}

echo "succuess,detail see ${attach}"

