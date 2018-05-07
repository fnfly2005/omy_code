#!/bin/bash
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

osr=`fun detail_wg_outstockrecords.sql` 
so=`fun detail_wg_saleorder.sql` 
sre=`fun detail_wg_salereminders.sql` 
use=`fun dim_wg_users.sql` 
mso=`fun detail_myshow_saleorder.sql`
smp=`fun dp_myshow__s_messagepush.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '\$\$today{-1d}' as dt,
    count(distinct mobile) as all_num,
    count(distinct case when dmi is not null then mobile end) as yc_num,
    count(distinct case when dma is not null then mobile end) as my_num,
    count(distinct case when dmi='\$\$today{-1d}' then mobile end) as n_num,
    count(distinct case when dma='\$\$today{-1d}' then mobile end) as t_num
from (
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.detail_wg_outstockrecords
    where
        mobile is not null 
        and length(mobile)=11 
        and substr(cast(mobile as varchar),1,2)>='13' 
    union all
    select
        order_mobile as mobile,
        case when length(pay_no)>0 then 'wg' 
        else NUll end as dmi,
        NUll as dma
    from upload_table.detail_wg_saleorder
    union all
    select
        mobile,
        case when length(pay_no)>4 then 'wp' 
        else NUll end as dmi,
        NUll as dma
    from upload_table.detail_wp_saleorder
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.detail_wg_salereminders
    where
        mobile is not null 
        and length(mobile)=11 
        and substr(cast(mobile as varchar),1,2)>='13' 
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.dim_wg_users
    where
        mobile is not null 
        and length(mobile)=11 
        and substr(cast(mobile as varchar),1,2)>='13' 
    union all
    select
        phonenumber as mobile,
        NUll as dmi,
        NUll as dma
    from origindb.dp_myshow__s_messagepush
    union all
    select
        usermobileno as mobile,
        min(substr(pay_time,1,10)) as dmi,
        max(substr(pay_time,1,10)) as dma
    from mart_movie.detail_myshow_saleorder
    group by
        1
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from upload_table.dim_wp_user
    union all
    select
        mobile,
        NUll as dmi,
        NUll as dma
    from mart_movie.dim_gp_user
    union all
    select
        UserMobileNo as mobile,
        NUll as dmi,
        NUll as dma
    from origindb.dp_myshow__s_stockoutregisterrecord
    ) as so
group by
    1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi

