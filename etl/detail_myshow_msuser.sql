/*'unique_keys': 'mobile,sendtag',*/
/*'format': 'mobile,send_date,batch_code,sendtag,etl_time',*/
insert OVERWRITE TABLE $delta.table
select
    mobile,
    send_date,
    batch_code,
    sendtag,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select distinct
        mobile,
        send_date,
        batch_code,
        sendtag
    from 
        upload_table.send_fn_user
    where
        mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
    union all 
    select distinct
        mobile,
        send_date,
        batch_code,
        sendtag
    from 
        upload_table.send_wdh_user
    where
        mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
    ) fw

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mobile` bigint COMMENT '电话号码',
`send_date` string COMMENT '发送日期',
`batch_code` bigint COMMENT '发送批次',
`sendtag` string COMMENT '发送标识',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色项目-营销人群记录表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
