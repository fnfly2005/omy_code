##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标库dsn名.目标表名

##Description##
##--演出数据字典

##TaskInfo##
creator = 'fannian@meituan.com'

source = {
    'db': META['horigindb'], ##-- 单引号内填写一个dsn库名，表示Extract阶段的SQL在哪个数据库里执行
}

stream = {
    'format': '', ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 与Extract节点的结果顺序对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号内填写目标库的dsn名
    'table': 'dim_myshow_dictionary', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的、读取数据的sql

##Preload##
##-- Preload节点, 这里填写一个能在target.db上执行的、load数据之前执行的sql(可以留空)

##Load##
##-- Load节点, 这里填写一个能在target.db上执行的、load数据的sql(可以留空)
insert OVERWRITE TABLE `$target.table`
select distinct
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
##-- 目标表表结构
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
