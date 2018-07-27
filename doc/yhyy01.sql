
select
    coalesce(sr_show_name,'all') sr_show_name,
    coalesce(sr_ticket_price,'all') sr_ticket_price,
    count(distinct sms.mobile) as sms_num
from (
    select distinct
        sm.mobile
    from (
        select substr(CreateTime,1,10) as dt, phonenumber as mobile, performanceid as performance_id from origindb.dp_myshow__s_messagepush where phonenumber is not null and CreateTime>'2018-03-01' and regexp_like(phonenumber,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$') and phonenumber not in (13800138000,13000000000)
            and performanceid in (49797,50160)
            and createtime>='2018-07-11'
            and createtime<'2018-07-25'
        ) sm
        left join (
            select
                usermobileno as mobile
            from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
                and performance_id in (50160)
            group by
                1
            ) so
            on so.mobile=sm.mobile
    where
        so.mobile is null
    ) sms
    left join (
        select
            mobile,
            case when 2 in (2) then show_name
            else 'all' end as sr_show_name,
            case when 2 in (2) then ticket_price
            else 'all' end as sr_ticket_price
        from (
            select stockoutregisterstatisticid, performanceid as performance_id, showid show_id, showname show_name, ticketprice as ticket_price from origindb.dp_myshow__s_stockoutregisterstatistic where 1=1
                and performanceid in (50160)
                and createtime>='2018-07-11'
                and createtime<'2018-07-25'
            ) srs
            left join (
                select stockoutregisterstatisticid, usermobileno as mobile, smssendstatus, sellchannel from origindb.dp_myshow__s_stockoutregisterrecord where 1=1
                and smssendstatus in (1,2,3)
                ) srr
            on srs.stockoutregisterstatisticid=srr.stockoutregisterstatisticid
        group by
            1,2,3
    ) as sr
    on sr.mobile=sms.mobile
group by
    1,2
;
