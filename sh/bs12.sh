#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
file="bs12"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    s1.mt,
    count(distinct s1.meituan_userid) l_u,
    count(distinct s2.meituan_userid) f_u
from (select
        substr(date_add('day',30,
            date_parse(
                substr(pay_time,1,10),
                '%Y-%m-%d')),1,7) as mt,
        meituan_userid 
    from
        (
        $so
        ) as so
    group by 1,2) as s1
    left join (
    select
        substr(pay_time,1,7) as mt,
        meituan_userid
    from
        (
        $so
        ) as so
    group by 1,2) as s2
    on s1.mt=s2.mt
    and s1.meituan_userid=s2.meituan_userid
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

