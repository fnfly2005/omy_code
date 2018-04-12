#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mso=`fun detail_myshow_saleorder.sql`
smp=`fun dp_myshow__s_messagepush.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '\$\$today{-1d}' as d,
    count(distinct bs.mobile) as mv_num,
    count(distinct so.mobile) as my_num,
    count(distinct case when bs.mobile is not null 
        then so.mobile end) as cr_num,
    count(distinct case when bs.mobile is not null 
                        and so.dt='\$\$today{-1d}'
                    then so.mobile end) as ncr_num
from (
    select distinct
        mobile
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
        ) as su
    ) as bs
    full join (
        select
            mobile,
            min(dt) dt
        from (
            select
                 usermobileno as mobile,
                 min(substr(order_create_time,1,10)) as dt
            from mart_movie.detail_myshow_saleorder
            where order_create_time<'\$\$today{-0d}'
            group by
                1
            union all
            select
                 phonenumber as mobile,
                 min(substr(createtime,1,10)) as dt
            from origindb.dp_myshow__s_messagepush
            where createtime<'\$\$today{-0d}'
            group by
                1
            ) s1
        group by
            1
        ) as so
    on bs.mobile=so.mobile
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

