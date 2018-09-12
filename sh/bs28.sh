#!/bin/bash
#历史销售-全量-多维度-多指标-多数据源
source ./fuc.sh

ssp=`fun detail_myshow_salesplan.sql u`
so=`fun detail_myshow_saleorder.sql u` 
spo=`fun detail_myshow_salepayorder.sql u` 
per=`fun dim_myshow_performance.sql`
cus=`fun dim_myshow_customer.sql`
md=`fun dim_myshow_dictionary.sql`
wso=`fun detail_wg_saleorder.sql u`
wi=`fun dim_wg_performance_s.sql`
scn=`fun detail_maoyan_order_sale_cost_new_info.sql u`
ddn=`fun dim_deal_new.sql u`
dsh=`fun dim_myshow_show.sql u`

file="bs28"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp.ds,
    sp.mt,
    sp.dt,
    sp.pt,
    sp.customer_type_name,
    sp.customer_lvl1_name,
    sp.category_name,
    sp.area_1_level_name,
    sp.area_2_level_name,
    sp.province_name,
    sp.city_name,
    sum(show_num) as show_num,
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit,
    sum(sp_num) as sp_num,
    sum(ap_num) as ap_num
from (
    select
        case when 0 in (\$dim) then '猫眼演出'
        else 'all' end as ds,
        case when 1 in (\$dim) then substr(dt,1,7) 
        else 'all' end mt,
        case when 2 in (\$dim) then dt
        else 'all' end dt,
        case when 3 in (\$dim) then value2
        else 'all' end pt,
        case when 4 in (\$dim) then customer_type_name
        else 'all' end customer_type_name,
        case when 5 in (\$dim) then customer_lvl1_name
        else 'all' end customer_lvl1_name,
        case when 6 in (\$dim) then category_name
        else 'all' end category_name,
        case when 7 in (\$dim) then area_1_level_name
        else 'all' end area_1_level_name,
        case when 8 in (\$dim) then area_2_level_name
        else 'all' end area_2_level_name,
        case when 9 in (\$dim) then province_name
        else 'all' end province_name,
        case when 10 in (\$dim) then city_name
        else 'all' end city_name,
        count(distinct spo.performance_id) as sp_num,
        sum(show_num) as show_num,
        sum(order_num) as order_num,
        sum(totalprice) as totalprice,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            dt,
            sellchannel,
            customer_id,
            performance_id,
            count(distinct sp1.show_id) as show_num,
            sum(order_num) as order_num,
            sum(totalprice) as totalprice,
            sum(ticket_num) as ticket_num,
            sum(grossprofit) as grossprofit
        from (
            select
                substr(order_create_time,1,10) as dt,
                sellchannel,
                customer_id,
                performance_id,
                show_id,
                count(distinct order_id) as order_num,
                sum(totalprice) as totalprice,
                sum(salesplan_count*setnumber) as ticket_num,
                0 as grossprofit
            from
                mart_movie.detail_myshow_saleorder
            where
                pay_time is null
                and order_create_time>='\$\$begindate'
                and order_create_time<'\$\$enddate'
                and \$payflag=0
                and 0 in (\$ds)
            group by
                1,2,3,4,5
            union all
            select
                partition_date as dt,
                sellchannel,
                customer_id,
                performance_id,
                show_id,
                count(distinct order_id) as order_num,
                sum(totalprice) as totalprice,
                sum(salesplan_count*setnumber) as ticket_num,
                sum(grossprofit) as grossprofit
            $spo
                and 0 in (\$ds)
            group by
                1,2,3,4,5
            union all
            select
                substr(pay_time,1,10) as dt,
                sellchannel,
                customer_id,
                performance_id,
                show_id,
                count(distinct order_id) as order_num,
                sum(totalprice) as totalprice,
                sum(salesplan_count*setnumber) as ticket_num,
                0 as grossprofit
            $so
                and 0 in (\$ds)
                and sellchannel in (9,10)
            group by
                1,2,3,4,5
            ) sp1
            join (
                select
                    show_id
                $dsh
                    and show_seattype in (\$show_seattype)
                ) dsh
                on dsh.show_id=sp1.show_id
        group by
            1,2,3,4
            ) spo
        join (
        $md
        and key_name='sellchannel'
        and value2 in ('\$pt')
        ) md1
        on md1.key=spo.sellchannel
        join (
        $per
        and category_id in (\$category_id)
        ) per
        on spo.performance_id=per.performance_id
        join (
        $cus
            and customer_type_id in (\$customer_type_id)
        ) cus
        on cus.customer_id=spo.customer_id
    group by
        1,2,3,4,5,6,7,8,9,10,11
    union all
    select
        case when 0 in (\$dim) then '微格演出'
        else 'all' end as ds,
        case when 1 in (\$dim) then substr(dt,1,7) 
        else 'all' end mt,
        case when 2 in (\$dim) then dt
        else 'all' end dt,
        case when 3 in (\$dim) then value2 
        else 'all' end as pt,
        case when 4 in (\$dim) then '自营' 
        else 'all' end as customer_type_name,
        case when 5 in (\$dim) then '微票开放平台' 
        else 'all' end as customer_lvl1_name,
        case when 6 in (\$dim) then category_name
        else 'all' end category_name,
        case when 7 in (\$dim) then area_1_level_name
        else 'all' end area_1_level_name,
        case when 8 in (\$dim) then area_2_level_name
        else 'all' end area_2_level_name,
        case when 9 in (\$dim) then province_name
        else 'all' end province_name,
        case when 10 in (\$dim) then city_name
        else 'all' end city_name,
        count(distinct wso.item_id) as sp_num,
        0 as show_num,
        sum(order_num) as order_num,
        sum(totalprice) as totalprice,
        0 as ticket_num,
        0 as grossprofit
    from (
        select
            dt,
            item_id,
            order_src,
            count(distinct order_id) as order_num,
            sum(total_money) as totalprice
        $wso
            and order_src<>10
            and (
                length(pay_no)>5
                or \$payflag=0
                )
            and 1 in (\$ds)
            and 2 in (\$customer_type_id)
        group by
            1,2,3
            ) wso
        join (
            $md
                and key_name='order_src'
                and value2 in ('\$pt')
            ) md2
        on wso.order_src=md2.key
        join (
            $wi
                and (category_id in (\$category_id)
                or 0 in (\$category_id))
            ) wi
        on wso.item_id=wi.item_id
    group by
        1,2,3,4,5,6,7,8,9,10,11
    union all
    select
        case when 0 in (\$dim) then '猫眼团购'
        else 'all' end as ds,
        case when 1 in (\$dim) then substr(pay_time,1,7) 
        else 'all' end mt,
        case when 2 in (\$dim) then substr(pay_time,1,10)
        else 'all' end dt,
        'all' pt,
        case when 4 in (\$dim) then '自营' 
        else 'all' end as customer_type_name,
        case when 5 in (\$dim) then '猫眼团购' 
        else 'all' end as customer_lvl1_name,
        'all' category_name,
        'all' area_1_level_name,
        'all' area_2_level_name,
        'all' province_name,
        'all' city_name,
        count(distinct deal_id) as sp_num,
        0 as show_num,
        count(distinct order_id) as order_num,
        sum(purchase_price) as totalprice,
        sum(quantity) as ticket_num,
        0 as grossprofit
    $scn
        and 2 in (\$ds)
        and deal_id in (
            select 
                deal_id
            $ddn
            )
    group by
        1,2,3,4,5,6,7,8,9,10,11
    ) as sp
    left join (
        select
            case when 0 in (\$dim) then '猫眼演出'
            else 'all' end as ds,
            case when 1 in (\$dim) then substr(dt,1,7) 
            else 'all' end mt,
            case when 2 in (\$dim) then dt
            else 'all' end dt,
            'all' as pt,
            case when 4 in (\$dim) then customer_type_name
            else 'all' end customer_type_name,
            case when 5 in (\$dim) then customer_lvl1_name
            else 'all' end customer_lvl1_name,
            case when 6 in (\$dim) then category_name
            else 'all' end category_name,
            case when 7 in (\$dim) then area_1_level_name
            else 'all' end area_1_level_name,
            case when 8 in (\$dim) then area_2_level_name
            else 'all' end area_2_level_name,
            case when 9 in (\$dim) then province_name
            else 'all' end province_name,
            case when 10 in (\$dim) then city_name
            else 'all' end city_name,
            count(distinct spo.performance_id) as ap_num
        from (
            select distinct
                partition_date as dt,
                customer_id,
                performance_id,
                show_id
            $ssp
                and salesplan_sellout_flag=0
                and customer_type_id in (\$customer_type_id)
                and category_id in (\$category_id)
                and 0 in (\$ds)
            ) spo
            join (
                select
                    show_id
                $dsh
                    and show_seattype in (\$show_seattype)
                ) as dsh
                on dsh.show_id=spo.show_id
            left join (
                $per
                and category_id in (\$category_id)
                ) per
            on spo.performance_id=per.performance_id
            left join (
                $cus
                and customer_type_id in (\$customer_type_id)
                ) cus
            on cus.customer_id=spo.customer_id
        group by
            1,2,3,4,5,6,7,8,9,10,11
        ) ss
    on sp.ds=ss.ds
    and sp.mt=ss.mt
    and sp.dt=ss.dt
    and sp.pt=ss.pt
    and sp.customer_type_name=ss.customer_type_name
    and sp.customer_lvl1_name=ss.customer_lvl1_name
    and sp.category_name=ss.category_name
    and sp.area_1_level_name=ss.area_1_level_name
    and sp.area_2_level_name=ss.area_2_level_name
    and sp.province_name=ss.province_name
    and sp.city_name=ss.city_name
group by
    1,2,3,4,5,6,7,8,9,10,11
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
