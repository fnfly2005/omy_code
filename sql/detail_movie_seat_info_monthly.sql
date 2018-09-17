/*美团电影选座订单表分月(BY 下单时间)*/
select
    cinema_city,
    movie_id,
    mobile_phone as mobile
from 
    mart_movie.detail_movie_seat_info_monthly
where
    ordermonth>=substr('$$begindatekey',1,6)
    and ordermonth<=substr('$$enddatekey',1,6)
