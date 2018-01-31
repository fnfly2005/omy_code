insert OVERWRITE TABLE `$target.table`
select
    customer_id,
    customer_code,
    customer_name,
    customer_shortname,
    customer_type_id,
    case when value3 is null then '自营'
    else value3 end as customer_type_name,
    customer_lvl1_id,
    case when value1 is null then '其他'
    else value1 end as customer_lvl1_name,
    customer_status,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from 
    (select
        TPID as customer_id,
        MYCustomerID as customer_code,
        Name as customer_name,
        ShortName as customer_shortname,
        case when supplierid in (1,2,3,4,5) then CustomerType 
        else 2 end as customer_type_id,
        supplierid as customer_lvl1_id,
        status as customer_status
    from origindb.dp_myshow__s_customer
    ) as sc
    left join
    (select
        key,
        value1,
        value3
    from
        upload_table.myshow_dictionary
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
`etl_time` string COMMENT '更新时间'
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
