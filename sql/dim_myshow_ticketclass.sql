/*票档维度表*/
select
    ticketclass_id,
    ticket_price,
    ticketclass_description,
    performance_id
from
    mart_movie.dim_myshow_ticketclass
where
    ticketclass_id is not null
