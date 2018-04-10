
select
    count(distinct mobile) as num
from (
    select
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end as mobile
    from (
        select item_id, mobile, dt from upload_table.detail_wg_outstockrecords
        ) osr
    union all
    select
         mobile
    from (
        select dt, item_id, order_id, order_src, user_id, order_mobile mobile, receive_mobile, pay_no, total_money from upload_table.detail_wg_saleorder
        ) so
    union all
    select
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end as mobile
    from (
        select dt, item_id, mobile from upload_table.detail_wg_salereminders
        ) sre
    union all
    select
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end as mobile
    from (
        select user_id, mobile, dt from upload_table.dim_wg_users
        ) use
    union all
    select
         mobile
    from (
        select order_id, maoyan_order_id, usermobileno as mobile, recipientidno, sellchannel, city_id, totalprice, customer_id, performance_id, meituan_userid, dianping_userid, pay_time, consumed_time, show_endtime, show_starttime, order_create_time, order_refund_status, setnumber, salesplan_count from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
        ) mso
    union all
    select
         mobile
    from (
        select phonenumber as mobile, performanceid as performance_id from origindb.dp_myshow__s_messagepush where phonenumber is not null
        ) smp
    ) as bs
;
