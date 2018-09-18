##Description##



##TaskInfo##
creator = 'fannian@meituan.com'

source = {
    'db': META['hmart_movie'], 
}

stream = {
    'format': '',
}

target = {
    'db': META['hmart_movie'], 
    'table': 'dim_myshow_pv', 
}

##Extract##


##Preload##
#if $isRELOAD
drop table `$target.table`
#end if

##Load##

insert OVERWRITE TABLE `$target.table`
select
    pv_id,
    page_identifier,
    page_name_my,
    cid_type,
    page_cat,
    biz_par,
    biz_bg,
    status,
    begin_date,
    end_date,
    page_intention,
    biz_bg_name
from 
    upload_table.my_pv_fn_v2

##TargetDDL##
CREATE TABLE IF NOT EXISTS `$target.table`
(
`pv_id` int COMMENT '配置ID',
`page_identifier` string COMMENT '标识',
`page_name_my` string COMMENT '名称',
`cid_type` string COMMENT '埋点类型',
`page_cat` int COMMENT '页面意向_id',
`biz_par` string COMMENT '业务参数',
`biz_bg` int COMMENT '业务归属_id',
`status` int COMMENT '是否最新',
`begin_date` string COMMENT '开链日期',
`end_date` string COMMENT '闭链日期',
`page_intention` string COMMENT '页面意向-名称',
`biz_bg_name` string COMMENT '业务归属-名称'
) COMMENT '演出页面埋点配置拉链表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
