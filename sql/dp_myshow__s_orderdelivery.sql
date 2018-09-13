/*快递记录表*/
select
    OrderID as order_id,
    ExpressFee,
    cityname as city_name,
    fetchedtime as fetched_time
from
    origindb.dp_myshow__s_orderdelivery
where
    1=1
