insert OVERWRITE TABLE `$target.table` PARTITION(partition_date='$now.date')
select
from
    mart_movie.detail_myshow_saleorder
select
from
    mart_movie.detail_myshow_salepayorder
select
from
    origindb.dp_myshow__s_orderdiscountdetail
select
from
    mart_movie.detail_myshow_salesplan

CREATE TABLE IF NOT EXISTS `$target.table`
(
`date_id` string COMMENT '日期',
`customer_type_name` string COMMENT '业务单元',
`sellchannel` string COMMENT '销售渠道',
`user_num_pay` bigint COMMENT '用户数-交易',
`order_num_pay` bigint COMMENT '订单数-交易',
`ticket_num_pay` bigint COMMENT '出票量-交易',
`gmv_pay` double COMMENT '交易额-交易',
`ticketprice_pay` double COMMENT '票款额-交易',
`discountaount_pay` double COMMENT '折扣额-交易',
`discountamount_pay_maoyan` double COMMENT '猫眼承担折扣额-交易',
`discountamount_pay_customer` double COMMENT '商家承担折扣额-交易',
`grossprofit_pay` double COMMENT '收入-交易',
`user_num_use` bigint COMMENT '用户数-消费',
`order_num_use` bigint COMMENT '订单数-消费',
`ticket_num_use` bigint COMMENT '出票量-消费',
`gmv_use` double COMMENT '交易额-消费',
`ticketprice_use` double COMMENT '票款额-消费',
`discountamount_use` double COMMENT '折扣额-消费',
`discountamount_use_maoyan` double COMMENT '猫眼承担折扣额-消费',
`discountamount_use_customer` double COMMENT '商家承担折扣额-消费',
`grossprofit_use` double COMMENT '收入-消费',
`online_citynum` bigint COMMENT '在线演出城市数',
`online_performancenum` bigint COMMENT '在线可售演出数',
`pay_performancenum` bigint COMMENT '有订单演出数',
`online_shownum` bigint COMMENT '在线可售场次数',
`pay_shownum` bigint COMMENT '有订单场次数',
`online_skunum` bigint COMMENT '在线可售sku数',
`pay_skunum` bigint COMMENT '有订单sku数',
`online_poinum` bigint COMMENT '在线可售店铺数',
`pay_poinum` bigint COMMENT '有订单店铺数',
`etl_time` string COMMENT '更新时间'
) partitioned by (partition_date string)
row format delimited
    fields terminated by '\t'
stored as orc
