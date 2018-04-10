
select
    dt,
    partner_name,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) ticket_num
from (
    select
        substr(pay_time,1,10) as dt,
        partner_name,
        so.order_id,
        setnumber*salesplan_count as ticket_num,
        totalprice
    from (
        select order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
        and performance_id in ($performance_id)
        and sellchannel=11
        ) so
        left join (
        select OrderID as order_id, PartnerID as partner_id from origindb.dp_myshow__s_orderpartner
        ) opa
        on so.order_id=opa.order_id
        left join (
        select PartnerID as partner_id, Name as partner_name from origindb.dp_myshow__s_partner
        ) par
        on opa.partner_id=par.partner_id
    ) as s1
group by
    1,2
;
