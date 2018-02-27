/*老电影手机号*/
select aa.mobile_phone
from mart_movie.detail_order_seat_info aa
left join mart_movie.dim_cinema bb on aa.cinema_id=bb.cinema_id
where aa.pay_status=1
and aa.fix_status=1
and bb.city_name in ('北京')
and aa.order_time>='2015-12-01 00:00:00'
and aa.order_time<'2016-05-01 00:00:00'
and get_json_object(aa.info_j,'$.movieName') LIKE '%极限挑战%'
GROUP BY aa.mobile_phone
