/*场次维表*/
select
    show_id,
    performance_id,
    substr(show_starttime,1,10) as show_starttime,
    show_endtime,
    show_name
from
    mart_movie.dim_myshow_show
where
    1=1
