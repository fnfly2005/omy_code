/*演出客户表*/
select
  TPID,
  Name
from
    S_Customer
where
    TPID is not null
