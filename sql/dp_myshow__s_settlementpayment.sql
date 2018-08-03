/*支付明细表*/
select
    OrderID as order_id,
    tpid as custom_id,
    paytime,
    totalprice,
    grossprofit,
    income,
    expense
from
    origindb.dp_myshow__s_settlementpayment
where
    paytime>='$$begindate'
    and paytime<'$$enddate'
