#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mom=`fun dim_movie_movie.sql` 
file="bd23"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    movie_id,
    name
from (
    $mom
    where
        releatime>='\$\$today{-12m}'
    ) mom
$lim">${attach}

echo "succuess,detail see ${attach}"

