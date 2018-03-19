/*微格选座订单表*/
select
    order_ticket.cert_no, 
	order_ticket.cert_name
from
    order_ticket
where
    order_ticket.cert_no is not null
    and (length(cert_no)=15
    or length(cert_no)=18)
    and substr(cert_no,1,2)>10
    and substr(cert_no,1,2)<83
    and substr(cert_no,7,4)>=1949
    and substr(cert_no,7,4)<2003
