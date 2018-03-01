/*影院维度表*/
select
    cinema_id,
    city_id
from
    mart_movie.dim_cinema
where
    cinema_id is not null
