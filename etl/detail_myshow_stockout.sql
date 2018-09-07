##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标表meta名(库名).表名

##Description##
##-- 这个节点填写本ETL的描述信息, 包括目标表定义, 建立时的需求jira编号等

##TaskInfo##
creator = 'fannian@maoyan.com'
tasktype = 'DeltaMerge'

source = {
    'db': META['horigindb'], ##-- 这里的单引号内填写在哪个数据库链接执行 Extract阶段, 具体有哪些链接请点击"查看META"按钮查看
}

stream = {
  'unique_keys': 'stockoutregisterrecordid',
    'format': 'stockoutregisterrecordid,mobile,dpuser_id,mtuser_id,sellchannel,smssendstatus,sendsmsuserid,status,version,createtime,updatetime,stockoutregisterstatisticid,performance_id,show_id,ticketclass_id,ticketprice,etl_time', ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 按照Extract节点的结果顺序做对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号中填写目标表所在库
    'table': 'detail_myshow_stockout', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)
#if $isRELOAD
drop table `$target.table`
#end if

##Load##
##-- Load节点, (可以留空)
set hive.auto.convert.join=true;
insert OVERWRITE TABLE `$delta.table`
select
    ord.stockoutregisterrecordid,
    ord.mobile,
    ord.dpuser_id,
    ord.mtuser_id,
    ord.sellchannel,
    ord.smssendstatus,
    ord.sendsmsuserid,
    ord.status,
    ord.version,
    ord.createtime,
    ord.updatetime,
    tic.stockoutregisterstatisticid,
    tic.performanceid as performance_id,
    tic.showid as show_id,
    tic.ticketclassid as ticketclass_id,
    tic.ticketprice,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as etl_time
from (
    select
        stockoutregisterrecordid,
        stockoutregisterstatisticid,
        usermobileno as mobile,
        dpuserid as dpuser_id,
        mtuserid as mtuser_id,
        sellchannel,
        smssendstatus,
        sendsmsuserid,
        status,
        version,
        createtime,
        updatetime
    from
        origindb.dp_myshow__s_stockoutregisterrecord 
    where
    #if $isRELOAD
        1=1
    #else
        to_date(updatetime)='$now.date'
    #end if
    ) as ord
    left join origindb.dp_myshow__s_stockoutregisterstatistic tic
    on ord.stockoutregisterstatisticid=tic.stockoutregisterstatisticid

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`stockoutregisterrecordid` bigint COMMENT '主键',
`mobile` string COMMENT '用户手机号',
`dpuser_id` bigint COMMENT '点评用户ID',
`mtuser_id` bigint COMMENT '美团用户ID',
`sellchannel` int COMMENT '销售渠道',
`smssendstatus` bigint COMMENT '短信发送状态,1未发送,2待发送,3已发送',
`sendsmsuserid` bigint COMMENT '发送短信用户id',
`status` int COMMENT '0无效1有效',
`version` bigint COMMENT '版本号',
`createtime` string COMMENT '创建时间',
`updatetime` string COMMENT '更新时间',
`stockoutregisterstatisticid` bigint COMMENT '缺货登记统计表ID',
`performance_id` bigint COMMENT '项目ID',
`show_id` bigint COMMENT '场次ID',
`ticketclass_id` bigint COMMENT '票档ID',
`ticketprice` double COMMENT '票面价',
`etl_time` string COMMENT '更新时间'
) COMMENT '演出缺货登记事实明细表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
