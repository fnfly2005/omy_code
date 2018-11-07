/*dysensitive用户池*/
select
    user_id,
    mobile,
    city_id,
    movie_id,
    active_date
from
    mart_movie.dim_myshow_movieuser
where
    active_date>='$$begindate'
    and active_date<'$$enddate'
