
#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
fpw=`fun detail_flow_pv_wide_report.sql`

file="bs15"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
from
    (
    $spo
    ) as spo
$lim">${attach}


echo "select
    substr(so.PaidTime,1,10) dt,
    sp.PerformanceID,
    sos.PerformanceName,
    bam.TPSProjectID,
    so.TPID,
    so.tp_type,
    sc.Name,
    count(distinct so.OrderID) Order_num,
    count(distinct so.MTUserID) user_num,
    count(distinct 
        case when so.RefundStatus='已退款' 
        then so.MTUserID end) re_user_num,
    sum(so.SalesPlanCount) sp_num,
    sum(so.TotalPrice) TotalPrice,
    sum(case when so.RefundStatus='已退款' 
        then so.TotalPrice end) re_TotalPrice,
    sum(sod.ExpressFee) ExpressFee,
    sum(so.SalesPlanCount*so.SalesPlanSupplyPrice) SupplyPrice
from
group by
    1,2,3,4,5,6,7;">${attach}

echo "select
    partition_date,
    count(distinct union_id) uv
from
    (
    $md
    and page_id=40000390
    and custom['performance_id']=$3
    ) md
group by
    1">>${attach}

echo "succuess,detail see ${attach}"
