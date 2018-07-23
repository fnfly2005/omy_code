/*演出用户画像*/
select
    user_id,
    mobile，
    category_flag,
    pay_num
from
    mart_movie.dim_myshow_userlabel
where
    user_id is not null
