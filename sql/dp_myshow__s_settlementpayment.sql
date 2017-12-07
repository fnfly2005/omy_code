/*支付明细表*/
select
    OrderID,
    GrossProfit
from
    origindb.dp_myshow__s_settlementpayment
where
    OrderID is not null
    and PayTime>='-time1'
    and PayTime<'-time2'
