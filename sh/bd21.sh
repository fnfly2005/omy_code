#!/bin/bash
source ./fuc.sh
per=`fun dim_myshow_performance.sql` 
spo=`fun detail_myshow_salepayorder.sql u`
so=`fun detail_wg_saleorder.sql`
dit=`fun dim_wg_performance_s.sql`
md=`fun dim_myshow_dictionary.sql`
dsh=`fun dim_myshow_show.sql u`
cus=`fun dim_myshow_customer.sql u`

file="bd21"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ds,
    mt,
    province_name,
    city_name,
    category_name,
    shop_name,
    performance_id,
    performance_name,
    totalprice,
    order_num,
    grossprofit,
    rank
from (
    select
        ds,
        mt,
        province_name,
        city_name,
        category_name,
        shop_name,
        performance_id,
        performance_name,
        totalprice,
        order_num,
        grossprofit,
        row_number() over (partition by \$par order by \$ord desc) rank
    from (
        select
            '猫眼演出' as ds,
            mt,
            per.province_name,
            per.city_name,
            per.category_name,
            per.shop_name,
            per.performance_id,
            per.performance_name,
            sum(totalprice) totalprice,
            sum(order_num) order_num,
            sum(grossprofit) as grossprofit
        from (
            $per
                and 1 in (\$source)
            ) as per
            join (
                select
                    mt,
                    performance_id,
                    sellchannel,
                    sum(totalprice) as totalprice,
                    sum(order_num) as order_num,
                    sum(grossprofit) as grossprofit
                from (
                    select
                        case when 1 in (\$dim) then substr(partition_date,1,7)
                        else 'all' end as mt,
                        performance_id,
                        customer_id,
                        sellchannel,
                        show_id,
                        sum(totalprice) as totalprice,
                        count(distinct order_id) as order_num,
                        sum(grossprofit) as grossprofit
                    $spo
                    group by
                        1,2,3,4,5
                    ) as spo
                    join (
                        select
                            show_id
                        $dsh
                            and show_seattype in (\$show_seattype)
                        ) dsh
                    on dsh.show_id=spo.show_id
                    join (
                        select
                            customer_id
                        $cus
                            and customer_type_id in (\$customer_type_id)
                        ) cus
                    on spo.customer_id=cus.customer_id
                group by
                    1,2,3
            ) as sp1
            on per.performance_id=sp1.performance_id
            join (
                $md
                and key_name='sellchannel'
                and value2 in ('\$pt')
                ) as md
            on md.key=sp1.sellchannel
        group by
            1,2,3,4,5,6,7,8
        union all
        select
            '微格演出' as ds,
            mt,
            province_name,
            city_name,
            category_name,
            shop_name,
            performance_id,
            performance_name,
            sum(totalprice) totalprice,
            sum(order_num) order_num,
            0 as grossprofit
        from (
            $dit
                and 2 in (\$source)
            ) dit
            join (
            select
                case when 1 in (\$dim) then substr(dt,1,7)
                else 'all' end as mt,
                item_id,
                order_src,
                sum(total_money) as totalprice,
                count(distinct order_id) as order_num
            from 
                upload_table.detail_wg_saleorder
            where 
                dt<'\$\$enddate'
                and dt>='\$\$begindate'
                and (pay_no is not null
                    or 1=\$pay_no)
                and 2 in (\$customer_type_id)
            group by
                1,2,3
            ) so
            on so.item_id=dit.item_id
            join (
                $md
                    and key_name='order_src'
                    and value2 in ('\$pt')
                ) md3
            on so.order_src=md3.key
        group by
            1,2,3,4,5,6,7,8
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
