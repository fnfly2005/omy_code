/*优惠券批次维表*/
select
    batch_id,
    batch_name,
    batch_value,
    validdatetype,
    undertakertype,
    validdays,
    begindate,
    enddate
from
    mart_movie.dim_myshow_batch
where
    batch_name not like '%测试%'
