/*电影订单对应来源渠道详情表*/
select
    cinema_id,
    mobile_phone
from 
    mart_movie.aggr_discount_card_seat_dwd
where
    pay_time>'2018-02-01'
    and pay_time>='$$begindate'
    and pay_time<'$$enddate'
