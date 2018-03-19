/*微格身份认证信息*/
select
    cert_no，
    cert_name
from
    order_cert_image
where
    is_checked=1
