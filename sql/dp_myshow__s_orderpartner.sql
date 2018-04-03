/*订单关联的分销商信息*/
select
    OrderID as order_id,
    PartnerID as partner_id
from
    origindb.dp_myshow__s_orderpartner
