##Description##
##-- 快递订单明细表-快递城市ID挖掘

##TaskInfo##
creator = 'fannian@maoyan.com'

source = {
    'db': META['horigindb'], 
}

stream = {
    'format': ''
}

target = {
    'db': META['hmart_movie'], 
    'table': 'detail_myshow_orderdelivery', 
}

##Load##
add file $Script('get_citykey.py');
set hive.exec.parallel=true;
set hive.exec.reducers.max =1000;
set mapreduce.reduce.memory.mb=4096;
set mapreduce.map.memory.mb=4096;
set mapred.child.java.opts=-Xmx3072m;
set hive.auto.convert.join=true;
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
    ity.city_id as dpcity_id,
    ery.order_id
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
        expressdetailid as expressdetail_id,
        orderid as order_id
    from 
        origindb.dp_myshow__s_orderdelivery
    ) as ery
    left join mart_movie.dim_myshow_city ity
    on ery.city_name=ity.city_name
;
insert OVERWRITE TABLE `$target.table`
select
	ery.orderdelivery_id,
	ery.fetchticketway_id,
	ery.fetch_type,
	ery.needidcard,
	ery.recipientidno,
	coalesce(ity.province_name,ery.province_name) as province_name,
	coalesce(ity.city_name,ery.city_name) as city_name,
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
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as etl_time,
    ery.order_id
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
                and city_name <> '海外'
            ) as ery_a
        ) as ery_k
    on ery.orderdelivery_id = ery_k.orderdelivery_id
    left join mart_movie.dim_myshow_city ity
    on ity.citykey = ery_k.citykey

##TargetDDL##
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
`etl_time` string COMMENT '更新时间',
`order_id` bigint COMMENT '用户预定记录ID'
) COMMENT '演出快递订单明细表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
