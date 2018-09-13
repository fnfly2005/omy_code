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
  'unique_keys': 'orderdelivery_id',
    'format': 'orderdelivery_id,fetchticketway_id,fetch_type,needidcard,recipientidno,province_name,city_name,district_name,detailedaddress,postcode,recipientname,recipientmobileno,expresscompany,expressno,expressfee,deliver_time,delivered_time,deliver_create_time,localeaddress,localecontactpersons,fetchcode,fetchqrcode,dpcity_id', ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 按照Extract节点的结果顺序做对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号中填写目标表所在库
    'table': 'detail_myshow_orderdelivery', ##-- 单引号中填写目标表名
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
add file $Script('get_citykey.py');
drop table if EXISTS mart_movie_test.detail_myshow_orderdelivery_tempa1;
create table mart_movie_test.detail_myshow_orderdelivery_tempa1 as
select
	ery.orderdelivery_id,
	ery.fetchticketway_id,
	ery.fetch_type,
	ery.needidcard,
	ery.recipientidno,
	ery.province_name,
	ery.city_name,
	ery.district_name,
	ery.detailedaddress,
	ery.postcode,
	ery.recipientname,
	ery.recipientmobileno,
	ery.expresscompany,
	ery.expressno,
	ery.expressfee,
	ery.deliver_time,
	ery.delivered_time,
	ery.deliver_create_time,
	ery.localeaddress,
	ery.localecontactpersons,
	ery.fetchcode,
	ery.fetchqrcode,
	ery.expressdetail_id,
    ity.city_id as dpcity_id
from (
    select
        orderdeliveryid as orderdelivery_id,
        fetchticketwayid as fetchticketway_id,
        fetchtype as fetch_type,
        needidcard,
        recipientidno,
        provincename as province_name,
        cityname as city_name,
        districtname as district_name,
        detailedaddress,
        postcode,
        recipientname,
        recipientmobileno,
        expresscompany,
        expressno,
        expressfee,
        delivertime as deliver_time,
        deliveredtime as delivered_time,
        createtime as deliver_create_time,
        localeaddress,
        localecontactpersons,
        fetchcode,
        fetchqrcode,
        expressdetailid as expressdetail_id
    from 
        origindb.dp_myshow__s_orderdelivery
    where
        #if $isRELOAD
            1=1
        #else
            to_date(updatetime)='$now.date'
        #end if
    ) as ery
    left join mart_movie.dim_myshow_city ity
    on ery.cityname=ity.city_name
;
insert OVERWRITE TABLE `$delta.table`
select
	ery.orderdelivery_id,
	ery.fetchticketway_id,
	ery.fetch_type,
	ery.needidcard,
	ery.recipientidno,
	ery.province_name,
	ery.city_name,
	ery.district_name,
	ery.detailedaddress,
	ery.postcode,
	ery.recipientname,
	ery.recipientmobileno,
	ery.expresscompany,
	ery.expressno,
	ery.expressfee,
	ery.deliver_time,
	ery.delivered_time,
	ery.deliver_create_time,
	ery.localeaddress,
	ery.localecontactpersons,
	ery.fetchcode,
	ery.fetchqrcode,
	coalesce(ery.dpcity_id,ity.city_id) as dpcity_id,
	ery.expressdetail_id,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as etl_time
from 
    mart_movie_test.detail_myshow_orderdelivery_tempa1 as ery
    left join (
        reduce *
            using 'python get_citykey.py'
        as
            orderdelivery_id,
            city_name,
            citykey
        from (
            select 
                orderdelivery_id,
                city_name
            from
                mart_movie_test.detail_myshow_orderdelivery_tempa1
            where
                dpcity_id is null
                and city_name is not null
                and city_name not like '%区划'
            ) as ery_a
        ) as ery_k
    on ery.orderdelivery_id=ery_k.orderdelivery_id
    left join mart_movie.dim_myshow_city ity
    on ity.citykey=ery_k.citykey

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`orderdelivery_id` bigint COMMENT '快递记录ID',
`fetchticketway_id` bigint COMMENT '取票方式ID',
`fetch_type` int COMMENT '取票方式 1:上门自取,2:快递,4&5:测试,7:临场派票',
`needidcard` int COMMENT '是否需要身份证取件 0:否, 1:是',
`recipientidno` string COMMENT '收件人身份证号',
`province_name` string COMMENT '省份名',
`city_name` string COMMENT '城市名',
`district_name` string COMMENT '区县名',
`detailedaddress` string COMMENT '收件人具体地址',
`postcode` string COMMENT '收件人邮编',
`recipientname` string COMMENT '收件人名',
`recipientmobileno` string COMMENT '收件人电话',
`expresscompany` string COMMENT '快递公司',
`expressno` string COMMENT '快递单号',
`expressfee` double COMMENT '配送费用',
`deliver_time` string COMMENT '开始配送时间',
`delivered_time` string COMMENT '配送完成时间',
`deliver_create_time` string COMMENT '添加时间',
`localeaddress` string COMMENT '现场取票的取票地点',
`localecontactpersons` string COMMENT '现场取票的联系人',
`fetchcode` string COMMENT '订单取票码',
`fetchqrcode` string COMMENT '订单取票二维码',
`dpcity_id` bigint COMMENT '点评城市ID',
`expressdetail_id` bigint COMMENT '快递明细ID',
`etl_time` string COMMENT '更新时间'
) COMMENT '演出快递订单明细表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
