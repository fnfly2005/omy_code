/*类目维度表*/
select
    category_id,
    category_name
from
    mart_movie.dim_myshow_category
where
    category_id is not null
