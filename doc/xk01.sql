
select
    dt,
    sell_type,
    sell_lv1_type,
    sum(totalprice) as totalprice,
    count(distinct order_id) as order_num,
    sum(ticket_num) ticket_num
from (
    select
        substr(pay_time,1,10) as dt,
        value2 as sell_type,
        case when partner_name is null 
            then value1
        else partner_name end as sell_lv1_type,
        case when ogi.order_id is null then 0
        else 1 end as gift_flag,
        so.order_id,
        setnumber*salesplan_count as ticket_num,
        totalprice
    from (
        select order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
        and sellchannel in (9,10,11)
        ) so
        left join (
        select OrderID as order_id, PartnerID as partner_id from origindb.dp_myshow__s_orderpartner
        ) opa
        on so.order_id=opa.order_id
        and so.sellchannel=11
        left join (
        select PartnerID as partner_id, Name as partner_name from origindb.dp_myshow__s_partner
        ) par
        on opa.partner_id=par.partner_id
        left join (
        select OrderID as order_id from origindb.dp_myshow__s_ordergift
        ) ogi
        on so.order_id=ogi.order_id
        and so.sellchannel in (9,10)
        left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='sellchannel'
        ) md
        on md.key=so.sellchannel
    ) as s1
where
    gift_flag=0
group by
    1,2,3
;
