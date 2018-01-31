/*商品维表*/
select
    project_id,
    insteaddelivery,
    bd_name
from
    mart_movie.dim_myshow_project
where
    project_id is not null
