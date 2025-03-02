{{ config(materialized="table") }}

with
    stores as (select * from {{ ref("stg_jaffle_shop__stores") }}),
    store_orders as (select * from {{ ref("int_store_orders_aggregated") }}),
    final as (
        select
            stores.store_id,
            stores.store_name,
            stores.tax_rate,
            stores.opened_at,
            coalesce(store_orders.number_of_orders, 0) as number_of_orders,
            coalesce(store_orders.total_order_amount, 0) as total_order_amount,
            coalesce(store_orders.avg_order_amount, 0) as avg_order_amount,
            coalesce(store_orders.total_tax_paid, 0) as total_tax_paid,
            store_orders.first_order_at,
            store_orders.last_order_at
        from stores
        left join store_orders using (store_id)
    )
select
    store_id,
    store_name,
    tax_rate,
    opened_at,
    number_of_orders,
    total_order_amount,
    avg_order_amount,
    total_tax_paid,
    date_part('day', current_date - opened_at) as store_age_days,
    case
        when date_part('day', current_date - opened_at) > 0
        then number_of_orders / date_part('day', current_date - opened_at)
        else null
    end as avg_daily_orders_since_opening,
    first_order_at,
    last_order_at
from final
