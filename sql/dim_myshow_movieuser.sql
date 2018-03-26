/*电影用户池*/
select
    mobile,
    city_id,
    active_date
from
    mart_movie.dim_myshow_movieuser
where
    active_date>='$$begindate'
    and active_date<'$$enddate'
    
