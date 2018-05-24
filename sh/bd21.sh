#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************项目历史数据-数据源*******************
#新增TOPX
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

per=`fun dim_myshow_performance.sql` 
spo=`fun detail_myshow_salepayorder.sql`
so=`fun detail_wg_saleorder.sql`
dit=`fun dim_wg_performance.sql`

file="bd21"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ds,
    province_name,
    city_name,
    category_name,
    shop_name,
    performance_id,
    performance_name,
    totalprice,
    order_num,
    rank
from (
    select
        ds,
        province_name,
        city_name,
        category_name,
        shop_name,
        performance_id,
        performance_name,
        totalprice,
        order_num,
        row_number() over (order by totalprice desc) rank
    from (
        select
            '范特西' as ds,
            per.province_name,
            per.city_name,
            per.category_name,
            per.shop_name,
            per.performance_id,
            per.performance_name,
            totalprice,
            order_num
        from (
            $per
                and (
                    regexp_like(performance_name,'\$name')=true
                    or '全部'='\$name'
                    )
                and (
                    -99 in (\$id)
                    or performance_id in (\$id)
                    )
                and 1 in (\$source)
            ) as per
            join (
            select
                performance_id,
                sum(totalprice) as totalprice,
                count(distinct order_id) as order_num
            from mart_movie.detail_myshow_salepayorder
            where
                partition_date<'\$enddate'
                and partition_date>='\$begindate'
            group by
                1
            ) as sp1
            on per.performance_id=sp1.performance_id
        union all
        select
            '微格' as ds,
            province_name,
            city_name,
            category_name,
            shop_name,
            item_no as performance_id,
            performance_name,
            totalprice,
            order_num
        from (
            $dit
                and (
                    regexp_like(performance_name,'\$name')=true
                    or '全部'='\$name'
                    )
                and (
                    -99 in (\$id)
                    or item_no in (\$id)
                    )
                and 2 in (\$source)
            ) dit
            join (
            select
                item_id,
                sum(total_money) as totalprice,
                count(distinct order_id) as order_num
            from 
                upload_table.detail_wg_saleorder
            where 
                dt<'\$enddate'
                and dt>='\$begindate'
                and pay_no is not null
            group by
                1
            ) so
            on so.item_id=dit.item_id
        ) as rs
    ) as rr
where
    rank<=\$rank
order by
    rank
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
