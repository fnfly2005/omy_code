#!/bin/bash
source ./fuc.sh

ssp=`fun dim_myshow_salesplan.sql u`
file="bs42"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    minperformance_id,
    shop_id,
    shop_name,
    performance_id,
    performance_name
from (
    select
        minperformance_id,
        shop_id,
        shop_name,
        performance_id,
        performance_name,
        dense_rank() over (order by minperformance_id) as rank
    from (
        select
            minperformance_id,
            ssp.shop_id,
            ssp.shop_name,
            array_agg(performance_id) as performance_id,
            array_agg(performance_name) as performance_name
        from (
            select
                substr(show_starttime,1,10) as show_startdate,
                shop_id,
                shop_name,
                min(performance_id) as minperformance_id
            $ssp
                and category_id in (1,2,9)
                and shop_id<>0
            group by
                1,2,3
            ) as ssp
            left join (
                select distinct
                    substr(show_starttime,1,10) as show_startdate,
                    shop_id,
                    performance_id,
                    performance_name
                $ssp
                ) as sps
                on sps.shop_id=ssp.shop_id
                and sps.show_startdate=ssp.show_startdate
        group by
            1,2,3
        having
            count(distinct performance_id)>1
            ) as dp
    ) dpr
where
    rank<=400
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
