select
    
from (
    select
        stat_time,
        app_name,
        page_identifier,
        union_id,
        user_id
    from
        mart_flow.detail_flow_pv_wide_report    
    where
        partition_date='$$today{-1d}'
        and partition_log_channel='movie'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
    ) as pv
    join (
    select
        nav_flag,
        value
    from
        upload_table.myshow_pv
    where
        key='page_identifier'
        and page_tag1>=-1
    ) as mp
    on pv.page_identifier=mp.value
    ) sp
insert OVERWRITE TABLE `$target.table` PARTITION(partition_date='$now.date')
select
    batch_id,
    lastmodifier,
    updatetime,
    totalstock,
    issuedcount,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from 
    mart_movie.dim_myshow_batch
where
    status=1

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`batch_id` bigint COMMENT '批次ID',
`lastmodifier` string COMMENT '最近修改者',
`updatetime` string COMMENT '修改时间',
`totalstock` bigint COMMENT '库存数',
`issuedcount` bigint COMMENT '已发送数',
`etl_time` string COMMENT '更新时间'
) COMMENT '猫眼演出优惠券批次周期快照表'
partitioned by (partition_date string)
row format delimited
    fields terminated by '\t'
stored as orc
