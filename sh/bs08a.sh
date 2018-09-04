#!/bin/bash
#团购月报数据
source ./fuc.sh
oni=`fun detail_maoyan_order_new_info.sql`
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`
fpw=`fun detail_flow_pv_wide_report.sql`

file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(pay_time,1,7) mt,
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
$lim">${attach}
echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
