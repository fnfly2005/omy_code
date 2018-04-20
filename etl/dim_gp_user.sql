insert OVERWRITE TABLE $delta.table
select
    ni.user_id,
    max(ni.mobile_phone) as mobile,
    max(ni.deal_id) as deal_id,
    max(substr(ni.order_time,1,10)) as dt
from 
    origindb.dp_myshow__s_deal dea
    left join mart_movie.detail_maoyan_order_new_info ni
    on dea.MYDealID=ni.deal_id
    and mobile_phone is not null
    and substr(ni.order_time,1,10)>='$now.month_begin_date.date'
    and substr(ni.order_time,1,10)<='$now.month_end_date.date'
    and ni.category=12
group by
    ni.user_id

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`user_id` bigint COMMENT '用户Id',
`mobile` string COMMENT '电话号码',
`deal_id` bigint COMMENT '猫眼团单ID',
`dt` string COMMENT '最近活跃时间'
) COMMENT '用户染色项目-猫眼演出团购用户池'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
