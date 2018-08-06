#!/bin/bash
path=""
fun() {
    tmp=`cat ${path}sql/${1} | grep -iv "/\*"`
    if [ -n $2 ];then
        if [[ $2 =~ d ]];then
            tmp=`echo $tmp | sed 's/where.*//'`
        fi
        if [[ $2 =~ u ]];then
            tmp=`echo $tmp | sed 's/.*from/from/'`
        fi
        if [[ $2 =~ t ]];then
            tmp=`echo $tmp | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
        fi
        if [[ $2 =~ m ]];then
            tmp=`echo $tmp | sed "s/begindate/monthfirst{-1m}/g;s/enddate/monthfirst/g"`
        fi
    fi
    echo $tmp
}

ssp=`fun dp_myshow__s_settlementpayment.sql`
so=`fun detail_myshow_saleorder.sql`
sor=`fun dp_myshow__s_orderrefund.sql`

file="cw02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mt,
    case when sor.order_id is null then 0
    else 1 end isrefund,
    sum(so.totalprice) as gmv,
    sum(income) as income,
    sum(expense) as expense
from (
    $so
        and sellchannel not in (5,7,8,9,10,11)
        ) so
    left join (
    $sor
        ) sor
    on sor.order_id=so.order_id
    left join (
    $ssp
        ) ssp
    on ssp.order_id=so.order_id
group by
    1,2
union all
select
    substr(sc.pay_time,1,7) as mt,
    case when yn=0 then 1
    else 0 end as isrefund,
    sum(purchase_price) as gmv,
    sum(purchase_price) as income,
    sum(purchase_price) as expense
from (
    select 
        pay_time,
        order_id,
        purchase_price
    from 
        mart_movie.detail_maoyan_order_sale_cost_new_info
    where 
        pay_time>='\$\$begindate'
        and pay_time<'\$\$enddate'
        and deal_id in (
            select deal_id
            from mart_movie.dim_deal_new
            where category=12
            )
    ) as sc
    left join mart_movie.detail_maoyan_order_new_info mon
    on mon.order_id=sc.order_id
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
