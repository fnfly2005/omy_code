#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
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

so=`fun detail_myshow_saleorder.sql u`
dub=`fun detail_user_base_info.sql`
sfo=`fun detail_myshow_salefirstorder.sql u`
cit=`fun dim_myshow_city.sql`

file="bs30"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    \$dim,
    count(distinct order_id) order_num
from (
    select
        case when sfo.meituan_userid is not null then '新客'
        else '老客' end new_flag,
        case when so.fetch_type=2 then so.province_name
        else cit.province_name end province_name,
        case when so.fetch_type=2 then so.city_name
        else cit.city_name end city_name,
        datediff(dt,birthday)/365 age,
        order_id
    from (
        select
            substr(pay_time,1,10) dt,
            province_name,
            city_name,
            fetch_type,
            order_id,
            meituan_userid
        $so
            and performance_id in (\$performance_id)
            ) so
        left join (
        $dub
        ) dub
        on dub.userid=so.meituan_userid
        left join (
        select
            meituan_userid,
            min(first_pay_order_date) first_pay_order_date
        $sfo
        group by
            meituan_userid
        ) sfo
        on sfo.meituan_userid=so.meituan_userid
        and sfo.first_pay_order_date=so.dt
        left join (
        $cit
        ) cit
        on cit.mt_city_id=dub.city_id
    ) sim
group by
    \$dim
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


