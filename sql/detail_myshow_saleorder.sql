/*订单明细表*/
select
    order_id,
    case sellchannel
        when 1 then '点评'
        when 2 then '美团'
        when 3 then '微信大众点评'
        when 4 then '微信搜索小程序'
        when 5 then '猫眼'
        when 6 then '微信钱包'
        when 7 then '微信钱包'
    else '其他' end as sellchannel,
    totalprice,
    customer_id,
    performance_id,
    pay_time
from
    mart_movie.detail_myshow_saleorder
where
    pay_time is not null
    and pay_time>='$time1'
    and pay_time<'$time2'
