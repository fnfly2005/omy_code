
select
    s1.mt,
    count(distinct s1.meituan_userid) l_u,
    count(distinct s2.meituan_userid) f_u
from (select
        substr(date_add('day',30,
            date_parse(
                substr(pay_time,1,10),
                '%Y-%m-%d')),1,7) as mt,
        meituan_userid 
    from
        (
        select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
        ) as so
    group by 1,2) as s1
    left join (
    select
        substr(pay_time,1,7) as mt,
        meituan_userid
    from
        (
        select order_id, sellchannel, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$time1' and pay_time<'$time2'
        ) as so
    group by 1,2) as s2
    on s1.mt=s2.mt
    and s1.meituan_userid=s2.meituan_userid
group by
    1
;
