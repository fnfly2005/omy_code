/*微格城市维度表*/
select
    city_id,
    city_name,
    province_id
from
    city
where
    city_name is not null
