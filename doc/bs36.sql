
select
    count(distinct so1.uid) as user_num,
    count(distinct sos1.uid) as ft_usern
from (
    select
        $user as uid,
        max($ht) ht
    from (
        select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
            and sellchannel not in (9,10,11)
            and (
                (meituan_userid<>0
                and '$user'='meituan_userid')
                or (usermobileno not in (13800138000,13000000000)
                    and usermobileno is not null
                    and '$user'='mobile')
                )
        ) so
    group by
        1
    ) so1
    left join (
        select
            $user as uid,
            max($ht) ht
        from (
            select substr(pay_time,1,7) as mt, substr(pay_time,1,10) as dt, order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, show_name, show_id, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, ticket_price, province_name, city_name, ticketclass_description, detailedaddress from mart_movie.detail_myshow_saleorder
            where
                pay_time is not null
                and pay_time>='$$begindate'
                and pay_time<'$$enddate{6m}'
                and sellchannel not in (9,10,11)
                and (
                    (meituan_userid<>0
                    and '$user'='meituan_userid')
                    or (usermobileno not in (13800138000,13000000000)
                        and usermobileno is not null
                        and '$user'='mobile')
                    )
            ) as sos
        group by
            1
        ) sos1
    on so1.uid=sos1.uid
    and so1.ht<sos1.ht
;
