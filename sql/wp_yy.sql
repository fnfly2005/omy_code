i/*周报-新上架（包含o2o推过来）*/
SELECT b.business_user_name 'BD',a.id'项目id',a.item_no'项目编号',a.title_cn'项目名称',a.name'品类',a.city_name'城市名称',a.time'上架时间',
case when a.source=209 then '微格o2o'
else '其他'
end as '来源'
from 
(SELECT i.item_no,i.id,p.name,i.title_cn,c.city_name,a.time,i.source
from 
(SELECT a.item_id,a.business_id,a.agency_fees,FROM_UNIXTIME(left(a.pubon_time,10))'time'from item_pubon a  union all 
SELECT b.item_id,b.business_id,b.agency_fees,FROM_UNIXTIME(left(b.pubon_time,10))'time' from item_puboff b   )a,
item_info i,city c,business_base_info b,app_access l,item_match_channel m,item_type p
where a.item_id=i.id and i.city_id=c.city_id and b.business_id=a.business_id and l.id=m.app_access_id and m.item_id=i.id and i.type_pid=p.id
and left(a.time,10)>= SUBDATE(CURDATE(),7)
and left(a.time,10)<CURDATE()
and business_name not like "%测试%"
and l.order_sourcce not in (1,5,6)
and p.name not in ('测试项目')
and (i.title_cn not like "%测试%" and i.title_cn not like "%调试%" and i.title_cn not like "%勿动%" and i.title_cn not like "%test%" and i.title_cn not like "%废%"  and i.title_cn not like "%ceshi%")
GROUP BY i.id) a
left join item_balance b on a.id=b.item_id
GROUP BY a.id


/*周报-销售（退款前，线上）*/
SELECT b.business_user_name 'BD',a.id'项目Id',a.item_no'项目编号',a.title_cn'项目名称',a.name'品类',a.city_name '城市',
case when a.order_Src=2 then '微信钱包'
when a.order_Src=7 then 'm站'
when a.order_Src=8 then '娱票andriod'
when a.order_Src=9 then '娱票ios'
when a.order_Src=10 then '猫眼'
when a.order_Src=11 then '喵特'
when a.order_Src=12 then '手Q'
when a.order_Src=13 then '开心麻花'
when a.order_Src=14 then '小程序'
when a.order_Src=15 then '格瓦拉andriod'
when a.order_Src=16 then '格瓦拉ios'
when a.order_Src=20 then '京东'
when a.order_Src=21 then '格瓦拉'
end as '渠道',
sum(a.sale)'销售额',sum(a.num)'销售票张数',
case when b.balance_type=1 then '按折扣比例'
when b.balance_type=2 then '按固定金额'
when b.balance_type=3 then '其他'
end as '结算类型',b.balance_info '结算信息'
from (
SELECT o.order_id,i.id,i.item_no,i.title_cn,p.name,c.city_name,o.order_src,o.total_money/100'sale',count(distinct t.ticket_id)'num'
from order_form o,order_ticket t,item_info i,item_type p,city c
where o.order_id=t.order_id
and t.item_id=i.id
and i.type_pid=p.id
and i.city_id=c.city_id
and o.payment_status!=0
and o.order_Src not in (1,5,6)
and left(FROM_UNIXTIME(o.create_time/1000),10)<CURDATE()
and left(FROM_UNIXTIME(o.create_time/1000),10)>=SUBDATE(curdate(),7)
and (t.item_name not like "%测试%" and t.item_name not like "%调试%" and t.item_name not like "%勿动%" and t.item_name not like "%test%" and t.item_name not like "%ceshi%")
and (t.venue_name not like "%测试%" and t.venue_name  not like "%ceshi%")
and (t.show_name not like "%测试%" and t.show_name  not like "%ceshi%")
and (t.price_name not like "%测试%" and t.price_name  not like "%ceshi%")
and (t.venue_name not like "%测试%" and t.venue_name  not like "%ceshi%")
and p.name not in ('测试项目')
GROUP BY o.order_id)a left join item_balance b on a.id=b.item_id
GROUP BY a.id,渠道

/*周报-周五在线项目*/
SELECT b.business_user_name 'BD',a.id'项目id',a.item_no'项目编号',a.title_cn'项目名称',a.name'品类',a.city_name'城市'
from 
(SELECT i.id,i.item_no,i.title_cn,p.name,c.city_name
from 
(SELECT a.item_id,a.business_id,a.agency_fees,FROM_UNIXTIME(left(a.pubon_time,10))'time'from item_pubon a where left(FROM_UNIXTIME(a.pubon_time/1000),10)<curdate() union all 
SELECT item_id,b.business_id,b.agency_fees,FROM_UNIXTIME(left(b.pubon_time,10))'time' from item_puboff b  where left(FROM_UNIXTIME(b.puboff_time/1000),10)>CURDATE() and 
left(FROM_UNIXTIME(b.pubon_time/1000),10)<CURDATE())a,
item_info i,city c,business_base_info b,item_match_channel m,app_access l,item_type p
where a.item_id=i.id and i.city_id=c.city_id and b.business_id=a.business_id 
and m.item_id=i.id and m.app_access_id=l.id and i.type_pid=p.id
and b.business_name not like "%测试%"
and p.name not in ('测试项目')
and l.order_Sourcce not in (1,5,6)
and (i.title_cn not like "%测试%" and i.title_cn not like "%调试%" and i.title_cn not like "%勿动%" and i.title_cn not like "%test%" and i.title_cn not like "%废%"  and i.title_cn not like "%ceshi%")
GROUP BY i.id)a left join item_balance b on a.id=b.item_id
GROUP BY a.id
