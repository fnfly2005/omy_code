
select
    movie_id,
    name
from (
    select id, name from movie_mis.dim_movie_movie
    where
        releatime>='$$today{-12m}'
    ) mom
;
