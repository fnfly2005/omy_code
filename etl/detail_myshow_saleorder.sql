##Description##
##清洗快递城市名称并新增快递点评城市ID，新增BD、合同等数据，融合结算订单表、结算账单表、退款订单表逻辑，新增平台分层逻辑，新增分区字段，切换hive至spark引擎)

##TaskInfo##
creator = 'fannian@maoyan.com'

source = {
    'db': META['horigindb'], 
}

stream = {
    'format': '', 
}

target = {
    'db': META['hmart_movie'], 
    'table': 'detail_myshow_saleorder', 
}

##Load##
add file $Script('get_citykey.py');
set hive.exec.parallel=true;
set hive.exec.reducers.max =1000;
set mapreduce.reduce.memory.mb=4096;
set mapreduce.map.memory.mb=4096;
set mapred.child.java.opts=-Xmx3072m;
set hive.auto.convert.join=true;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE `$target.table` PARTITION (partition_sellchannel,partition_payflag)
select
    der.orderid as order_id,
    der.sellchannel,
    der.clientplatform,
    der.dpuserid as dianping_userid,
    der.mtuserid as meituan_userid,
    der.usermobileno,
    der.dpcityid as city_id,
    der.salesplanid as salesplan_id,
    der.salesplansupplyprice as supply_price,
    der.salesplansellprice as sell_price,
    der.salesplancount as salesplan_count,
    der.totalprice,
    der.myorderid as maoyan_order_id,
    der.tpid as customer_id,
    der.tporderid,
    der.reservestatus as order_reserve_status,
    der.deliverstatus as order_deliver_status,
    der.refundstatus as order_refund_status,
    der.createtime as order_create_time,
    der.lockedtime,
    der.payexpiretime,
    der.paidtime as pay_time,
    der.ticketedtime as ticketed_time,
    der.showstatus,
    der.wxopenid,
    der.prepayid as prepay_id,
    der.needrealname,
    der.consumedtime as consumed_time,
    der.needseat,
    der.totalticketprice,
    hot.ordersalesplansnapshotid as ordersalesplansnapshot_id,
    hot.performanceid as performance_id,
    hot.performancename as performance_name,
    hot.shopname as shop_name,
    hot.ticketid as ticketclass_id,
    hot.ticketname as ticketclass_description,
    hot.showid as show_id,
    hot.showname as show_name,
    hot.showstarttime as show_starttime,
    hot.showendtime as show_endtime,
    hot.salesplanname as salesplan_name,
    hot.isthrough as show_isthrough,
    hot.setnum as setnumber,
    hot.salesplanticketprice as ticket_price,
    hot.tpshowid,
    hot.tpsalesplanid,
    hot.agenttype as agent_type,
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
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') as etl_time,
    der.printstatus,
    der.notprintticketprice,
    hot.showtype,
    hot.projectid as project_id,
    hot.contractid as contract_id,
    hot.bduserid as bd_id,
    hot.bdusername as bd_name,
    enl.settlementpayment_id,
    enl.bill_id,
    enl.income,
    enl.expense,
    enl.grossprofit,
    enl.takerate,
    enl.discountamount,
    enl.mydiscountamount,
    enl.settlementuserid,
    enl.settlementcreatetime,
    enl.settlementtype,
    ery.dpcity_id as deliverydpcity_id,
    ary.key2 as sellchannel_lv1,
    ery.expressdetail_id,
    und.finishtime,
    enl.payfinishtime,
    enl.paymentstatus,
    coalesce(ary.key1,0) as partition_sellchannel,
    case when der.paidtime is null then 0
        when und.finishtime is not null then 2 
    else 1 end partition_payflag
from 
    origindb.dp_myshow__s_order der
    left join origindb.dp_myshow__s_ordersalesplansnapshot hot
    on der.orderid=hot.orderid
    left join mart_movie.detail_myshow_orderdelivery as ery
    on der.orderid=ery.order_id
    left join (
        select
            ent.orderid,
            ent.settlementpaymentid as settlementpayment_id,
            ent.billid as bill_id,
            ent.income,
            ent.expense,
            ent.grossprofit,
            ent.takerate,
            ent.discountamount,
            ent.mydiscountamount,
            ent.settlementuserid,
            ent.settlementcreatetime,
            ent.settlementtype,
            ill.payfinishtime,
            ill.paymentstatus
        from 
            origindb.dp_myshow__s_settlementpayment ent
            left join origindb.dp_myshow__s_settlementbill ill
            on ent.billid=ill.settlementbillid
            and ent.billid<>0
        ) enl
    on der.orderid=enl.orderid
    and der.paidtime is not null 
    left join (
        select
            cast(key as int) key,
            cast(key1 as int) key1,
            cast(key2 as int) key2
        from 
            mart_movie.dim_myshow_dictionary 
        where
            key_name='sellchannel'
        ) as ary
    on der.sellchannel=ary.key
    left join (
        select 
            orderid,
            finishtime,
            row_number() over (partition by orderid order by orderrefundid desc) rrank
        from
            origindb.dp_myshow__s_orderrefund
            ) und
    on der.orderid=und.orderid
    and der.refundstatus<>0
    and der.paidtime is not null
    and und.rrank=1
;
##TargetDDL##
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
`province_name` string COMMENT '快递省份名',
`city_name` string COMMENT '快递城市名',
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
`etl_time` string COMMENT '更新时间',
`printstatus` int COMMENT '打票状态0:未打票1:打票失败2打票成功',
`notprintticketprice` int COMMENT '是否不打印票面价',
`showtype` int COMMENT '场次类型 1为单场票 2 通票 3 连票 ',
`project_id` bigint COMMENT '商品ID',
`contract_id` string COMMENT '合同ID',
`bd_id` bigint COMMENT 'BD用户ID',
`bd_name` string COMMENT 'BD用户名称',
`settlementpayment_id` bigint COMMENT '结算支付明细表主键',
`bill_id` bigint COMMENT '账单id',
`income` double COMMENT '代收',
`expense` double COMMENT '应付',
`grossprofit` double COMMENT '毛收入',
`takerate` double COMMENT '抽成比例',
`discountamount` double COMMENT '优惠金额',
`mydiscountamount` double COMMENT '猫眼优惠金额',
`settlementuserid` bigint COMMENT '结算标记人ID',
`settlementcreatetime` string COMMENT '结算标记时间',
`settlementtype` bigint COMMENT '结算类型（1自动2人工)',
`deliverydpcity_id` bigint COMMENT '收件人城市ID',
`sellchannel_lv1` int COMMENT '平台一级分类 0 其他1 点评,2 美团,3 微信吃喝玩乐,4 微信演出赛事,5 猫眼,6 格瓦拉,7 api分销,8 演出M站,9 批量出票',
`expressdetail_id` bigint COMMENT '快递明细ID',
`finishtime` string COMMENT '退款流程完成时间',
`payfinishtime` string COMMENT '结算账单支付终态时间(成功或者失败)',
`paymentstatus` int COMMENT '结算账单支付状态，0-未支付 1-支付中 2-支付成功 3-支付失败'
) COMMENT '演出订单事实明细表'
PARTITIONED BY (
`partition_sellchannel` int COMMENT '平台分类 0 批量出票 1 内部平台 2 外部平台',
`partition_payflag` int COMMENT '交易标识 0 未支付 1 已支付 2 已退款'
) STORED AS ORC;
