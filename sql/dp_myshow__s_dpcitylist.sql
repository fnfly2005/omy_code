/*点评城市维表*/
select
    cityid,
    ProvinceID,
    cityname
from
    origindb.dp_myshow__s_dpcitylist
where
    cityid is not null
