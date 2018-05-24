
select
    sendtag,
    batch_code,
    count(distinct sed.mobile) send_num,
    sum(case when valid_flag=1 then totalprice end) totalprice,
    sum(case when valid_flag=1 then order_num end) order_num,
    sum(case when valid_flag=0 then totalprice end) un_totalprice,
    sum(case when valid_flag=0 then order_num end) un_order_num
from (
    select distinct 
        mobile,
        sendtag,
        batch_code
    from 
        mart_movie.detail_myshow_msuser
    where
        sendtag in ('$sendtag') 
    ) sed
    left join (
    select
        usermobileno as mobile,
        case when performance_id in ($send_performance_id) 
            then 1
        else 0 end as valid_flag,
        sum(totalprice) totalprice,
        count(distinct order_id) order_num
    from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
    group by
        1,2
    ) so
    on so.mobile=sed.mobile
group by
    1,2
;
