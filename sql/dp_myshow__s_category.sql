/*类别表*/
select
    CategoryID,
    Name
from
    origindb.dp_myshow__S_Category
where
    CategoryID is not null
