/*电影订单对应来源渠道详情表*/
select
    cinema_id,
    mobile_phone
from 
    mart_movie.aggr_discount_card_seat_dwd
where
    mobile_phone is not null
    and order_time>='$$begindate'
    and order_time<'$$enddate'
