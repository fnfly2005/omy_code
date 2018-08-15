
select
    spo.dt,
    ht,
    mit,
    md.value2 as pt,
    case when 3 in ($dim) then customer_type_name
    else 'all' end as customer_type_name,
    case when 3 in ($dim) then customer_lvl1_name
    else 'all' end as customer_lvl1_name,
    area_1_level_name,
    area_2_level_name,
    province_name,
    city_name,
    category_name,
    shop_name,
    performance_id,
    performance_name,
    case when 4 in ($dim) then show_name
    else 'all' end as show_name,
    case when 6 in ($dim) then ticket_price
    else 'all' end as ticket_price,
    case when 6 in ($dim) then salesplan_name
    else 'all' end as salesplan_name,
    case when 5 in ($dim) then refund_flag
    else 'all' end as refund_flag,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num,
    sum(TotalPrice) as TotalPrice,
    sum(current_amount) as current_amount,
    sum(amount_gmv) as amount_gmv
from (
    select
        case when 1 in ($dim) then spo.dt
        else 'all' end as dt,
        case when 7 in ($dim) then ht
        else 'all' end as ht,
        case when 8 in ($dim) then (cast(substr(pay_time,15,1) as bigint)+1)*10
        else 'all' end as mit,
        case when 2 in ($dim) then spo.sellchannel
        else -99 end as sellchannel,
        spo.salesplan_id,
        case when sor.order_id is null then 'no'
        else 'yes' end as refund_flag,
        count(distinct spo.order_id) as order_num,
        sum(ticket_num) as ticket_num,
        sum(spo.TotalPrice) as TotalPrice
    from (
        select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, substr(pay_time,12,2) as ht, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress, salesplan_id, salesplan_name from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and sellchannel in ($sellchannel)
            and (performance_id in ($id)
                or -99 in ($id))
        ) spo
        left join (
            select orderid order_id from origindb.dp_myshow__s_orderrefund where 1=1 and finishtime is not null
            ) sor
        on sor.order_id=spo.order_id
    where (
        8 not in ($dim)
        and 7 not in ($dim)
            )
        or (ht>=$hts
            and ht<$hte
                )
    group by
        1,2,3,4,5,6
    union all
    select
        case when 1 in ($dim) then substr(pay_time,1,10)
        else 'all' end as dt,
        case when 7 in ($dim) then substr(pay_time,12,2)
        else 'all' end as ht,
        case when 8 in ($dim) then (cast(substr(pay_time,15,1) as bigint)+1)*10
        else 'all' end as mit,
        sellchannel,
        salesplan_id,
        'all' refund_flag,
        count(distinct order_id) as order_num,
        sum(salesplan_count*setnumber) as ticket_num,
        sum(TotalPrice) as TotalPrice
    from
        upload_table.detail_myshow_salerealorder
    where
        sellchannel in ($sellchannel)
        and pay_time is not null
        and pay_time>='$$begindate'
        and pay_time<'$$enddate'
        and (performance_id in ($id)
            or -99 in ($id))
        and $real=1
        and ((8 not in ($dim)
        and 7 not in ($dim)
            )
        or (substr(pay_time,12,2)>=$hts
            and substr(pay_time,12,2)<$hte
                ))
    group by
        1,2,3,4,5,6
        ) as spo
    join (
        select salesplan_id, salesplan_name, shop_id, category_name, show_starttime, performance_id, performance_name, show_id, show_name, ticketclass_id, ticket_price, salesplan_ontime, salesplan_createtime, customer_id, customer_name, customer_type_name, customer_lvl1_name, shop_name, city_name, area_1_level_name, area_2_level_name, province_name, setnumber from mart_movie.dim_myshow_salesplan where salesplan_id is not null
        and (regexp_like(customer_name,'$customer_name')
        or '全部'='$customer_name')
        and (customer_code in ($customer_code)
        or -99 in ($customer_code))
        and (regexp_like(performance_name,'$name')
        or '全部'='$name')
        and (performance_id in ($id)
            or -99 in ($id))
        and (regexp_like(shop_name,'$shop_name')
        or '全部'='$shop_name')
        ) ssp
        on spo.salesplan_id=ssp.salesplan_id
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
        and key_name='sellchannel'
        ) md
        on md.key=spo.sellchannel
    left join (
        select
            case when 1 in ($dim) then partition_date
            else 'all' end as dt,
            salesplan_id,
            sum(current_amount) as current_amount,
            sum(sell_price*current_amount) as amount_gmv
        from mart_movie.detail_myshow_salesplan where 1=1 and partition_date>='$$begindate' and partition_date<'$$enddate'
            and islimited=1
            and salesplan_sellout_flag=0
            and current_amount>=0
            and 2 not in ($dim)
            and 5 not in ($dim)
            and 7 not in ($dim)
            and 8 not in ($dim)
        group by
            1,2
        ) mss
    on spo.salesplan_id=mss.salesplan_id
    and spo.dt=mss.dt
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
;
