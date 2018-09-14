##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标表meta名(库名).表名

##Description##
##-- 这个节点填写本ETL的描述信息, 包括目标表定义, 建立时的需求jira编号等

##TaskInfo##
creator = 'fannian@maoyan.com'

source = {
    'db': META['horigindb'], ##-- 这里的单引号内填写在哪个数据库链接执行 Extract阶段, 具体有哪些链接请点击"查看META"按钮查看
}

stream = {
    'format': '', ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 按照Extract节点的结果顺序做对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号中填写目标表所在库
    'table': 'detail_myshow_saleorder', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)

##Load##
##-- Load节点, (可以留空)
insert OVERWRITE TABLE `$target.table`
select so.orderid as order_id,
       so.sellchannel,
       so.clientplatform,
       so.dpuserid as dianping_userid,
       so.mtuserid as meituan_userid,
       so.usermobileno,
       so.dpcityid as city_id,
       so.salesplanid as salesplan_id,
       so.salesplansupplyprice as supply_price,
       so.salesplansellprice as sell_price,
       so.salesplancount as salesplan_count,
       so.totalprice,
       so.myorderid as maoyan_order_id,
       so.tpid as customer_id,
       so.tporderid,
       so.reservestatus as order_reserve_status,
       so.deliverstatus as order_deliver_status,
       so.refundstatus as order_refund_status,
       so.createtime as order_create_time,
       so.lockedtime,
       so.payexpiretime,
       so.paidtime as pay_time,
       so.ticketedtime as ticketed_time,
       so.showstatus,
       so.wxopenid,
       so.prepayid as prepay_id,
       so.needrealname,
       case when so.paidtime is null then so.consumedtime
       when sod.fetchtype=6 then 
            case when ds.show_endtime>'$now.now()' then so.consumedtime 
            when so.consumedtime is null then ds.show_endtime 
            else so.consumedtime end
       else ds.show_endtime end as consumed_time,
       so.needseat,
       so.totalticketprice,
       sos.ordersalesplansnapshotid as ordersalesplansnapshot_id,
       sos.performanceid as performance_id,
       sos.performancename as performance_name,
       sos.shopname as shop_name,
       sos.ticketid as ticketclass_id,
       sos.ticketname as ticketclass_description,
       sos.showid as show_id,
       sos.showname as show_name,
       sos.showstarttime as show_starttime,
       ds.show_endtime,
       sos.salesplanname as salesplan_name,
       sos.isthrough as show_isthrough,
       sos.setnum as setnumber,
       sos.salesplanticketprice as ticket_price,
       sos.tpshowid,
       sos.tpsalesplanid,
       sos.agenttype as agent_type,
       sod.orderdeliveryid as orderdelivery_id,
       sod.fetchticketwayid as fetchticketway_id,
       sod.fetchtype as fetch_type,
       sod.needidcard,
       sod.recipientidno,
       sod.provincename as province_name,
       sod.cityname as city_name,
       sod.districtname as district_name,
       sod.detailedaddress,
       sod.postcode,
       sod.recipientname,
       sod.recipientmobileno,
       sod.expresscompany,
       sod.expressno,
       sod.expressfee,
       sod.delivertime as deliver_time,
       sod.deliveredtime as delivered_time,
       sod.createtime as deliver_create_time,
       sod.localeaddress,
       sod.localecontactpersons,
       sod.fetchcode,
       sod.fetchqrcode,
       dis.discountamount,
       dci.deliverydpcity_id,
       from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
    from 
        origindb.dp_myshow__s_order as so
        left join origindb.dp_myshow__s_ordersalesplansnapshot sos
        on so.orderid=sos.orderid
        left join origindb.dp_myshow__s_orderdelivery as sod
        on so.orderid=sod.orderid
        left join mart_movie.dim_myshow_show as ds
        on sos.showid=ds.show_id
        left join mart_movie.dim_myshow_dictionary ary
        on so.sellchannel=ary.key
        and ary.key_name='sellchannel'
        left join origindb.dp_myshow__s_settlementpayment ent
        on so.orderid=ent.orderid
        and so.pay_time is not null
        and ary.key1>'0'
        left join origindb.dp_myshow__s_orderpartner ner
        on so.orderid=ner.orderid
        and ary.key1='2'
        left join origindb.dp_myshow__s_ordergift ift
        on so.orderid=ift.orderid
        and ary.key1='0'

        left join upload_table.dim_myshow_deliverycity dci
        on dci.deliverycity_name=sod.cityname
##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`order_id` bigint COMMENT '主预定ID',
`sellchannel` int COMMENT '销售渠道 1:点评,2:美团,3:微信大众点评,4:微信搜索小程序,5:猫眼,6:微信钱包-old,7:微信钱包-new,8:其他',
`clientplatform` int COMMENT '客户端平台 1:android,2:ios',
`dianping_userid` bigint COMMENT '点评用户ID',
`meituan_userid` bigint COMMENT '美团用户ID',
`usermobileno` string COMMENT '用户手机号',
`city_id` bigint COMMENT '点评CityID',
`salesplan_id` bigint COMMENT '销售计划ID',
`supply_price` double COMMENT '供应价=结算价',
`sell_price` double COMMENT '单售价',
`salesplan_count` bigint COMMENT '销售计划数量=销售数量',
`totalprice` double COMMENT '订单总价=票款+快递费',
`maoyan_order_id` bigint COMMENT '猫眼订单ID',
`customer_id` bigint COMMENT '第三方ID S_Customer',
`tporderid` string COMMENT '供应方订单ID 前台显示',
`order_reserve_status` int COMMENT '预定状态 0:已创建,1:锁座失败,2:已取消,3:已锁座,4:支付超时,5:支付失败,6:支付成功,7:出票中,8:出票失败,9:已出票',
`order_deliver_status` int COMMENT '配送状态 0:未配送,1:配送中,2:配送失败,3:已配送',
`order_refund_status` int COMMENT '退款状态 0，未发起，1发起失败，2发起成功，3退款中，4退款失败，5已退款',
`order_create_time` string COMMENT '创建订单时间',
`lockedtime` string COMMENT '锁座成功时间',
`payexpiretime` string COMMENT '支付超时时间大于创建时间15分钟',
`pay_time` string COMMENT '支付成功时间',
`ticketed_time` string COMMENT '出票成功时间',
`showstatus` int COMMENT '范特西后台展示状态 1:展示,2:不展示',
`wxopenid` string COMMENT '用户微信OpenID',
`prepay_id` string COMMENT '预支付ID（微信消息推送时需要用到）',
`needrealname` int COMMENT '是否实名制订单 0:否, 1:是',
`consumed_time` string COMMENT '消费时间',
`needseat` int COMMENT '是否是选座订单 0:否, 1:是',
`totalticketprice` double COMMENT '票款=平均售价*销售数量',
`ordersalesplansnapshot_id` bigint COMMENT '交易时销售计划快照ID',
`performance_id` bigint COMMENT '演出ID',
`performance_name` string COMMENT '演出名称',
`shop_name` string COMMENT '商户名',
`ticketclass_id` bigint COMMENT '票类ID 票档ID',
`ticketclass_description` string COMMENT '票类名称',
`show_id` bigint COMMENT '场次ID ',
`show_name` string COMMENT '场次名称',
`show_starttime` string COMMENT '场次开始时间',
`show_endtime` string COMMENT '场次结束时间',
`salesplan_name` string COMMENT '销售计划名称',
`show_isthrough` int COMMENT '是否通票',
`setnumber` bigint COMMENT '套票数量',
`ticket_price` double COMMENT '票面价',
`tpshowid` string COMMENT '第三方场次ID（如果有）',
`tpsalesplanid` string COMMENT '第三方销售计划ID（如果有）',
`agent_type` int COMMENT '代理第三方类型 1:总代理,2:分销商',
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
`discountamount` double COMMENT '实际优惠金额',
`etl_time` string COMMENT '更新时间',
`printstatus` int COMMENT '打票状态0:未打票1:打票失败2打票成功',
`notprintticketprice` int COMMENT '是否不打印票面价',
`partner_id` bigint COMMENT '分销商id',
`gift_flag` int COMMENT '是否赠票',
`showtype` int COMMENT '场次类型 1为单场票 2 通票 3 连票 ',
`project_id` bigint COMMENT '商品ID',
`contract_id` string COMMENT '合同ID',
`bd_id` bigint COMMENT 'BD用户ID',
`bd_name` string COMMENT 'BD用户名称',
`settlementpayment_id` bigint COMMENT '结算支付明细表主键',
`bill_id` bigint COMMENT '账单id',
`lastshowtime` string COMMENT '最后一场演出时间',
`income` double COMMENT '代收',
`expense` double COMMENT '应付',
`grossprofit` double COMMENT '毛收入',
`takerate` double COMMENT '抽成比例',
`discountamount` double COMMENT '优惠金额',
`mydiscountamount` double COMMENT '猫眼优惠金额',
`settlementuserid` bigint COMMENT '结算标记人ID',
`settlementusername` string COMMENT '结算标记人名称',
`settlementcreatetime` string COMMENT '结算标记时间',
`settlementtype` bigint COMMENT '结算类型（1自动2人工)',
`deliverydpcity_id` bigint COMMENT '收件人城市ID',
`channel_type` string COMMENT '平台类型 0 非GMV统计范围 1 内部平台 2 外部平台'
) COMMENT '猫眼演出订单事实明细表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
stored as orc
