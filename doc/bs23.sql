
select
    count(distinct mobile) as mob_num
from (
    select
        mobile
    from
        mart_movie.dim_myshow_movieuser
    union all
    select
        mobile
    from
        mart_movie.dim_myshow_movieusera
    ) as mob
;
