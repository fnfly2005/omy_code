/*猫眼数据字典*/
select
    key_name,
    key,
    key1,
    key2,
    value1,
    value2,
    value3,
    value4
from
    upload_table.myshow_dictionary_s
where
    key_name is not null
