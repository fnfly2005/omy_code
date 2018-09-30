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
    'table': 'dim_myshow_mv', 
}

##Extract##

##Preload##

##Load##

insert OVERWRITE TABLE `$target.table`
select
    mv_id,
    event_id,
    event_name_lv1,
    event_name_lv2,
    page_identifier,
    biz_tag,
    biz_par,
    biz_typ,
    page_loc,
    status,
    begin_date,
    end_date,
    page_name_my,
    cid_type,
    operation_flag,
    user_intention,
    page_cat,
    biz_bg
from 
    upload_table.myshow_sdk_mv

##TargetDDL##
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mv_id` int COMMENT '配置ID',
`event_id` string COMMENT '标识',
`event_name_lv1` string COMMENT '一级模块名',
`event_name_lv2` string COMMENT '二级模块名',
`page_identifier` string COMMENT '所属页面',
`biz_tag` bigint COMMENT '用户意向-id',
`biz_par` string COMMENT '业务参数',
`biz_typ` string COMMENT '逻辑字段',
`page_loc` int COMMENT '页面位置',
`status` int COMMENT '是否最新',
`begin_date` string COMMENT '开链日期',
`end_date` string COMMENT '闭链日期',
`page_name_my` string COMMENT '页面名称',
`cid_type` string COMMENT '埋点逻辑类型',
`operation_flag` int COMMENT '是否运营位 0 否 1 是',
`user_intention` string COMMENT '用户意向-名称',
`page_cat` int COMMENT '页面意向-id',
`biz_bg` int COMMENT '业务归属-id'
) COMMENT '演出模块埋点配置拉链表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
