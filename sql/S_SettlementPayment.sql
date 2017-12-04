/*支付结算表*/
select
    GrossProfit,
    TPID,
    case when TPID<6 then "渠道"
    else "自营" end tp_type
from
    S_SettlementPayment
where
    SettlementPaymentID is not null
    and PayTime>='-time1'
    and PayTime<'-time2'
