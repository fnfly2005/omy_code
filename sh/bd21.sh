#!/bin/bash
source ./fuc.sh
per=`fun dim_myshow_performance.sql` 
spo=`fun detail_myshow_salepayorder.sql u`
so=`fun detail_wg_saleorder.sql`
dit=`fun dim_wg_performance.sql`
md=`fun myshow_dictionary.sql`
dsh=`fun dim_myshow_show.sql u`
cus=`fun dim_myshow_customer.sql`

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
        row_number() over (partition by \$par order by totalprice desc) rank
    from (
        select
            '范特西' as ds,
            mt,
            per.province_name,
            per.city_name,
            per.category_name,
            per.shop_name,
            per.performance_id,
            per.performance_name,
            sum(totalprice) totalprice,
            sum(order_num) order_num
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
                    mt,
                    performance_id,
                    sellchannel,
                    sum(totalprice) as totalprice,
                    sum(order_num) as order_num
                from (
                    select
                        case when 1 in (\$dim) then substr(partition_date,1,7)
                        else 'all' end as mt,
                        performance_id,
                        customer_id,
                        sellchannel,
                        show_id,
                        sum(totalprice) as totalprice,
                        count(distinct order_id) as order_num
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
            '微格' as ds,
            mt,
            province_name,
            city_name,
            category_name,
            shop_name,
            item_no as performance_id,
            performance_name,
            sum(totalprice) totalprice,
            sum(order_num) order_num
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
                case when 1 in (\$dim) then substr(dt,1,7)
                else 'all' end as mt,
                item_id,
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
                1,2
            ) so
            on so.item_id=dit.item_id
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
