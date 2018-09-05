##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标库dsn名.目标表名

##Description##
##-- 这个节点填写本ETL的描述信息, 包括目标表定义, 建立时的需求jira编号等

##TaskInfo##
creator = 'fannian@meituan.com'

source = {
    'db': META['hmart_movie'], ##-- 单引号内填写一个dsn库名，表示Extract阶段的SQL在哪个数据库里执行
}

stream = {
    'format': '',
}

target = {
    'db': META['hmart_movie'], ##-- 单引号内填写目标库的dsn名
    'table': 'dim_myshow_mv', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的、读取数据的sql

##Preload##
##-- Preload节点, 这里填写一个能在target.db上执行的、load数据之前执行的sql(可以留空)
#if $isRELOAD
drop table `$target.table`
#end if

##Load##
##-- Load节点, 这里填写一个能在target.db上执行的、load数据的sql(可以留空)
insert OVERWRITE TABLE `$target.table`
select
    mv_id,
    event_id,
    event_name_lv1,
    event_name_lv2,
    page_identifier,
    user_int,
    biz_par,
    biz_typ,
    page_loc,
    status,
    begin_date,
    end_date,
    page_name_my,
    cid_type,
    operation_flag
from 
    upload_table.my_mv_fn_s

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mv_id` int COMMENT '配置ID',
`event_id` string COMMENT '标识',
`event_name_lv1` string COMMENT '一级模块名',
`event_name_lv2` string COMMENT '二级模块名',
`page_identifier` string COMMENT '所属页面',
`user_int` int COMMENT '用户意向',
`biz_par` string COMMENT '业务参数',
`biz_typ` string COMMENT '逻辑字段',
`page_loc` int COMMENT '页面位置',
`status` int COMMENT '是否最新',
`begin_date` string COMMENT '开链日期',
`end_date` string COMMENT '闭链日期',
`page_name_my` string COMMENT '页面名称',
`cid_type` string COMMENT '埋点逻辑类型',
`operation_flag` int COMMENT '是否运营位 0 否 1 是'
) COMMENT '演出模块埋点配置拉链表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
