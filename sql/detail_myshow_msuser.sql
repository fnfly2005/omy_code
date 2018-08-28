/*用户染色项目-营销人群记录表*/
select
    sendtag,
    etl_time
from
    mart_movie.detail_myshow_msuser
where
    etl_time>='$$begindate'
    and etl_time<'$$enddate'
