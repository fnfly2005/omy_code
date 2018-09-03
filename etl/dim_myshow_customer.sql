##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标表meta名(库名).表名

##Description##
##-- 这个节点填写本ETL的描述信息, 包括目标表定义, 建立时的需求jira编号等

##TaskInfo##
creator = 'fannian@maoyan.com'

source = {
    'db': META['horigindb'], ##-- 这里的单引号内填写在哪个数据库链接执行 Extract阶段, 具体有哪些链接请点击"查看META"按钮查看
}

stream = {
    'format': '', ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 按照Extract节点的结果顺序做对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号中填写目标表所在库
    'table': 'dim_myshow_customer', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)

##Load##
##-- Load节点, (可以留空)
insert OVERWRITE TABLE `$target.table`
select
    customer_id,
    customer_code,
    customer_name,
    customer_shortname,
    case when key is null then CustomerType
    else key1 end as customer_type_id,
    case when key is null then CustomerType_name
    else value3 end as customer_type_name,
    customer_lvl1_id,
    case when key is null then customer_shortname
    else value1 end as customer_lvl1_name,
    customer_status,
    customer_createtime,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select
        TPID as customer_id,
        MYCustomerID as customer_code,
        Name as customer_name,
        CustomerType,
        case when CustomerType=1 then '渠道'
        else '自营' end as CustomerType_name,
        ShortName as customer_shortname,
        supplierid as customer_lvl1_id,
        createtime as customer_createtime,
        status as customer_status
    from origindb.dp_myshow__s_customer
    ) as sc
    left join (
        select
            key,
            key1,
            value1,
            value3
        from
            mart_movie.dim_myshow_dictionary
        where
            key_name='customer_lvl1_id'
        ) as dic
    on dic.key=sc.customer_lvl1_id
;


##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`customer_id` bigint COMMENT '客户id',
`customer_code` bigint COMMENT '客户code',
`customer_name` string COMMENT '客户名称',
`customer_shortname` string COMMENT '客户简称',
`customer_type_id` int COMMENT '业务单元id',
`customer_type_name` string COMMENT '业务单元名称',
`customer_lvl1_id` int COMMENT '客户1级分类id',
`customer_lvl1_name` string COMMENT '客户1级分类名称',
`customer_status` int COMMENT '客户状态，0：无效 1：有效 2：禁用',
`customer_createtime` string COMMENT '创建时间',
`etl_time` string COMMENT '更新时间'
) COMMENT '猫眼演出供应商维度表' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
