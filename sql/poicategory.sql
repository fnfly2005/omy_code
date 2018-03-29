/*POI类目维度表*/
select
    typeid,
    typename,
    classid,
    classname
from
    dim.poicategory
where
    classid in (3,1854)
