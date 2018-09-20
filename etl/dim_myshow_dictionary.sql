##Description##
##--演出数据字典

##TaskInfo##
creator = 'fannian@meituan.com'

source = {
    'db': META['horigindb'], 
}

stream = {
    'format': '', 
}

target = {
    'db': META['hmart_movie'], 
    'table': 'dim_myshow_dictionary', 
}

##Extract##


##Preload##


##Load##

insert OVERWRITE TABLE `$target.table`
select
    key_name,
    key,
    key1,
    key2,
    value1,
    value2,
    value3,
    value4,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
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
    union all
    select
        'category_id' as key_name,
        category_id as key,
        null as key1,
        null as key2,
        category_name as value1,
        category_name as value2,
        category_name as value3,
        category_name as value4
    from
        mart_movie.dim_myshow_category
    union all
    select
        'partner_id' as key_name,
        partnerid as key,
        null as key1,
        null as key2,
        partner_name as value1,
        partner_name as value2,
        partner_name as value3,
        partner_name as value4
    from
        origindb.dp_myshow__s_partner
    ) as mds

##TargetDDL##

CREATE TABLE IF NOT EXISTS `$target.table`
(
`key_name` string COMMENT '字段名称',
`key` string COMMENT '字段值',
`key1` string COMMENT '扩展值1',
`key2` string COMMENT '扩展值2',
`value1` string COMMENT '字段解释1',
`value2` string COMMENT '字段解释2',
`value3` string COMMENT '字段解释3',
`value4` string COMMENT '字段解释4',
`etl_time` string COMMENT '更新时间'
) COMMENT '演出数据字典'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
stored as orc
