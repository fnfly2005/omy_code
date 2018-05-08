/*猫眼注册用户信息详情表*/
select
    userid,
    birthday,
    city_id
from
    mart_movie.detail_user_base_info
where
    userid is not null
    and (length(birthday)=10
        or city_id<>0)
