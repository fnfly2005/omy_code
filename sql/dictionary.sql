/*数据字典表*/
select
    dict_key,
    dict_value
from
    dictionary
where
    group_name is not null
