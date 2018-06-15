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
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/today{-7d}/today{-1d}/g;s/today{-0d}/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/today{-7d}/today{-1d}/g;s/today{-0d}/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

ss=`fun dim_myshow_salesplan.sql`
so=`fun detail_myshow_saleorder.sql u`
file="xk04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '\$\$today{-1d}' as dt,
    area_1_level_name,
    sum(seat_num) as seat_num,
    sum(ticket_num) as ticket_num
from (
    select
        area_1_level_name,
        city_name,
        shop_id,
        show_starttime,
        seat_num,
        sum(ticket_num) as ticket_num
    from (
        select distinct
            area_1_level_name,
            shs.shop_id,
            city_name,
            performance_name,
            show_id,
            substr(show_starttime,1,10) as show_starttime,
            seat_num
        from (
            select
                shop_id,
                cast(seat_num as bigint) as seat_num
            from
                upload_table.shop_seat
            ) shs
            left join (
                $ss
                where
                    show_endtime>='\$\$today{-7d}'
                    and show_endtime<'\$\$today{-0d}'
                    and category_id=1
                    and performance_name not like '%测试%'
                ) ss
            on ss.shop_id=shs.shop_id
        where
            shop_name is not null
        ) as sop
        left join (
            select
                show_id,
                sum(setnumber*salesplan_count) as ticket_num
            from
                mart_movie.detail_myshow_saleorder
            where
                pay_time is not null
            group by
                1
            ) so
        on so.show_id=sop.show_id
    group by
        1,2,3,4,5
    ) sos
group by
    1,2
union all
select
    '\$\$today{-1d}' as dt,
    '全部' as area_1_level_name,
    sum(seat_num) as seat_num,
    sum(ticket_num) as ticket_num
from (
    select
        area_1_level_name,
        city_name,
        shop_id,
        show_starttime,
        seat_num,
        sum(ticket_num) as ticket_num
    from (
        select distinct
            area_1_level_name,
            shs.shop_id,
            city_name,
            performance_name,
            show_id,
            substr(show_starttime,1,10) as show_starttime,
            seat_num
        from (
            select
                shop_id,
                cast(seat_num as bigint) as seat_num
            from
                upload_table.shop_seat
            ) shs
            left join (
                $ss
                where
                    show_endtime>='\$\$today{-7d}'
                    and show_endtime<'\$\$today{-0d}'
                    and category_id=1
                    and performance_name not like '%测试%'
                ) ss
            on ss.shop_id=shs.shop_id
        where
            shop_name is not null
        ) as sop
        left join (
            select
                show_id,
                sum(setnumber*salesplan_count) as ticket_num
            from
                mart_movie.detail_myshow_saleorder
            where
                pay_time is not null
            group by
                1
            ) so
        on so.show_id=sop.show_id
    group by
        1,2,3,4,5
    ) sos
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
