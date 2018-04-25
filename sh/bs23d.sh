#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}


file="bs23"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(distinct mobile) as mob_num
from (
    select
        mobile
    from
        mart_movie.dim_myshow_movieuser
    union all
    select
        mobile
    from
        mart_movie.dim_myshow_movieusera
    ) as mob
$lim">${attach}

echo "succuess,detail see ${attach}"

