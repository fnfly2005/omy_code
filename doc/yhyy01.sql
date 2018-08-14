
select
    sr_show_name,
    sr_ticket_price,
    value2 as pt,
    coalesce(show_name,'all') as show_name,
    coalesce(ticket_price,'all') as ticket_price,
    count(distinct sr.mobile) as sr_num,
    count(distinct so.mobile) as so_num,
    sum(totalprice) as totalprice,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num
from (
    select
        mobile,
        sellchannel,
        case when 2 in ($dim) then show_name
        else 'all' end as sr_show_name,
        case when 2 in ($dim) then ticket_price
        else 'all' end as sr_ticket_price
    from (
        select stockoutregisterstatisticid, performanceid as performance_id, showid show_id, showname show_name, ticketprice as ticket_price from origindb.dp_myshow__s_stockoutregisterstatistic where 1=1
            and performanceid in ($performance_id)
        ) srs
        join (
            select stockoutregisterstatisticid, usermobileno as mobile, smssendstatus, sellchannel, mtuserid from origindb.dp_myshow__s_stockoutregisterrecord where 1=1
            and createtime>='$str_date'
            and createtime<'$end_date'
            and smssendstatus in ($status)
            ) srr
        on srs.stockoutregisterstatisticid=srr.stockoutregisterstatisticid
    group by
        1,2,3,4
    ) as sr
    left join (
        select
            usermobileno as mobile,
            case when 4 in ($dim) then show_name
            else 'all' end as show_name,
            case when 4 in ($dim) then ticket_price
            else 'all' end as ticket_price,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(setnumber*salesplan_count) as ticket_num
        from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and performance_id in ($performance_id)
        group by
            1,2,3
        ) so
        on so.mobile=sr.mobile
    left join (
        
            and key_name='sellchannel'
        ) md
        on md.key=sr.sellchannel
group by
    1,2,3,4,5
;
