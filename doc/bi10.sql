
select
    sendtag,
    count(1) as num
from mart_movie.detail_myshow_msuser where etl_time>='$$today{-1d}' etl_time<'$$today{-0d}'
group by
    1
;
