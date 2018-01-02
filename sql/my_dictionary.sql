/*猫眼数据字典*/
select
    key,
    value1,
    value2,
    value3
from
    upload_table.dictionary001
where
    key_name is not null
