insert OVERWRITE TABLE `$target.table`
select
    coupongroupid as batch_id,
    title as batch_name,
    description,
    denomination as batch_value,
    type as batch_type,
    validdatetype,
    status,
    undertakertype,
    undertakerid,
    creator,
    lastmodifier,
    addtime,
    updatetime,
    begindate,
    enddate,
    issueenddate,
    validdays,
    totalstock,
    issuedcount,
    budgetserialno,
    isopen,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from 
    origindb.dp_myshowcoupon__s_coupongroup
;


##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`batch_id` bigint COMMENT '主键',
`batch_name` string COMMENT '优惠标题',
`description` string COMMENT '优惠描述',
`batch_value` double COMMENT '优惠金额,面额',
`batch_type` int COMMENT '类型 1:抵用券 2:优惠代码 ',
`validdatetype` int COMMENT '类型 1:时间范围 2:领取后多长时间有效 ',
`status` int COMMENT '状态 0:未发布 -1:已下线 1:正常',
`undertakertype` int COMMENT '类型 1:猫眼 2:商家 ',
`undertakerid` string COMMENT '承担方ID',
`creator` string COMMENT '创建者',
`lastmodifier` string COMMENT '最近修改者',
`addtime` string COMMENT '创建时间',
`updatetime` string COMMENT '修改时间',
`begindate` string COMMENT '开始时间',
`enddate` string COMMENT '结束时间',
`issueenddate` string COMMENT '发券截止时间',
`validdays` bigint COMMENT '领取后有效天数',
`totalstock` bigint COMMENT '库存数',
`issuedcount` bigint COMMENT '已发送数',
`budgetserialno` string COMMENT '预算流水号',
`isopen` int COMMENT '是否公开到美团领券中心',
`etl_time` string COMMENT '更新时间'
) COMMENT '猫眼演出优惠券批次维表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
