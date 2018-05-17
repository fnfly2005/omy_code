#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

oni=`fun detail_maoyan_order_new_info.sql`
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`
fpw=`fun detail_flow_pv_wide_report.sql`

file="bs28"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    so.dt,
    totalprice,
    order_num,
    sku_num,
    rehi_totalprice,
    rehi_order_num
from (
    select 
        cni.dt,
        cni.totalprice,
		cni.order_num,
		cni.sku_num,
		oni.rehi_totalprice,
		oni.rehi_order_num
    from (
        select
            substr(pay_time,1,7) dt,
            sum(purchase_price) as totalprice,
            count(distinct order_id) as order_num,
            sum(quantity) as sku_num
        from
            mart_movie.detail_maoyan_order_sale_cost_new_info
        where
            pay_time is not null
            and pay_time>='\$\$begindate'
            and pay_time<'\$\$enddate'
            and deal_id in (
                select
                    deal_id
                from
                    mart_movie.dim_deal_new
                where
                    category=12
                    )
        group by
            1
        ) cni
        left join (
            select
                substr(dt,1,7) dt,
                count(distinct order_id) as rehi_order_num,
                sum(totalprice) as rehi_totalprice
            from (
                select
                    substr(modified,1,10) dt,
                    order_id,
                    total_money/100 totalprice
                from
                    mart_movie.detail_maoyan_order_new_info
                where
                    pay_time is not null
                    and category=12
                    and yn=0
                    and modified>='\$\$begindate'
                    and modified<'\$\$enddate'
                    and pay_time<'\$\$begindate'
                ) on1
            group by
                1
            ) oni
        on oni.dt=cni.dt
    ) as so
$lim">${attach}
echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
