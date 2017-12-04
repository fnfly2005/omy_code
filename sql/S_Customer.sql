/*演出客户表*/
select
  TPID,
  Name,
  ShortName
from
    S_Customer
where
    TPID is not null
