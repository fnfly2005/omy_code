
select
    ite.*,
    cim.city_id dp_city_id,
    cyp.category_id
from upload_table.dim_wg_item ite
    left join upload_table.dim_wg_citymap cim
    on ite.city_name=cim.city_name
    left join upload_table.dim_wg_type cyp
    on ite.type_lv1_name=cyp.type_lv1_name
;
