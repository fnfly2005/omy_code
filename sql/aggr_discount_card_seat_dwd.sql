/*电影订单对应来源渠道详情表*/
select
    cinema_city,
    movie_id,
    mobile_phone as mobile
from 
    mart_movie.aggr_discount_card_seat_dwd
where
    month>=substr('$$begindatekey',1,6)
    and month<=substr('$$enddatekey',1,6)
