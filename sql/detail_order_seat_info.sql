/*电影订单对应来源渠道详情表*/
select
    cinema_id,
    mobile_phone
from 
    mart_movie.detail_order_seat_info
where
    pay_time<'2018-02-01'
    and pay_time>='$$begindate'
