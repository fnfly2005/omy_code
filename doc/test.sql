
from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$today{-1d}' and pay_time<'$$today{-0d}'
;
