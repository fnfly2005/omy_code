##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板只适合HIVE计算引擎
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
  'unique_keys': '',
    'format': '', 
    ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 按照Extract节点的结果顺序做对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号中填写目标表所在库
    'table': '', ##-- 单引号中填写目标表名
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
insert OVERWRITE TABLE `$delta.table`
select
from 
where
    #if $isRELOAD
        1=1
    #else
        to_date()='$now.date'
    #end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
) COMMENT ''
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
