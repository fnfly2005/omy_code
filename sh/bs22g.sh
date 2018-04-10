#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

osr=`fun detail_wg_outstockrecords.sql` 
so=`fun detail_wg_saleorder.sql` 
sre=`fun detail_wg_salereminders.sql` 
use=`fun dim_wg_users.sql` 
mso=`fun detail_myshow_saleorder.sql`
smp=`fun dp_myshow__s_messagepush.sql`

file="bs22"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(distinct mobile) as num
from (
    select
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end as mobile
    from (
        $osr
        ) osr
    union all
    select
         mobile
    from (
        $so
        ) so
    union all
    select
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end as mobile
    from (
        $sre
        ) sre
    union all
    select
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end as mobile
    from (
        $use
        ) use
    union all
    select
         mobile
    from (
        $mso
        ) mso
    union all
    select
         mobile
    from (
        $smp
        ) smp
    ) as bs
$lim">${attach}

echo "succuess,detail see ${attach}"

