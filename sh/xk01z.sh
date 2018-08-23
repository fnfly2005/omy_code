#!/bin/bash
source ./fuc.sh

md=`fun myshow_dictionary.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '\$\$today{-1d}' as dt,
    lv1_type,
    sum(case when dt='\$\$today{-1d}' then totalprice end) as totalprice,
    sum(totalprice) as mtd_totalprice
from (
    select
        substr(pay_time,1,10) dt,
        '团购' as lv1_type,
        sum(purchase_price) as totalprice
    from
        mart_movie.detail_maoyan_order_sale_cost_new_info
    where
        pay_time is not null
        and pay_time>='\$\$yesterday_monthfirst'
        and pay_time<'\$\$today{-0d}'
        and deal_id in (
            select
                mydealid
            from
                origindb.dp_myshow__s_deal
                )
    group by
        1,2
    union all
    select
        dt,
        value4 as lv1_type,
        sum(totalprice) as totalprice
    from (
        select
            substr(pay_time,1,10) as dt,
            sellchannel,
            sum(totalprice) as totalprice
        from
            mart_movie.detail_myshow_saleorder
        where
            pay_time is not null
            and pay_time>='\$\$yesterday_monthfirst'
            and pay_time<'\$\$today{-0d}'
        group by
            1,2
        ) so
        join (
            $md
            and key_name='sellchannel'
            and key1<>'0'
            ) md
        on so.sellchannel=md.key
    group by
        1,2
    union all
    select
        dt,
        '演出' as lv1_type,
        sum(totalprice) as totalprice
    from
        upload_table.sale_offline
    where
        dt is not null
        and dt>='\$\$yesterday_monthfirst'
        and dt<'\$\$today{-0d}'
    group by
        1,2
    ) as sot
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
