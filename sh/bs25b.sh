#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

per=`fun dim_myshow_performance.sql`
psr=`fun dp_myshow__s_performancesaleremind.sql` 
md=`fun myshow_dictionary.sql`
file="bs25"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(CreateTime,1,10) as dt,
    count(distinct phonenumber) mp_num
from
    origindb.dp_myshow__s_messagepush
where
    phonenumber is not null
    and CreateTime>='\$\$begindate'
    and CreateTime<'\$\$enddate'
    and sellchannel<>8
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"
