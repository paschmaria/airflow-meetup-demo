{{ config(materialized="ephemeral") }}

with
    orders as (select * from {{ ref("stg_jaffle_shop__orders") }}),
    store_orders as (
        select
            store_id,
            count(order_id) as number_of_orders,
            sum(order_total) as total_order_amount,
            avg(order_total) as avg_order_amount,
            sum(tax_paid) as total_tax_paid,
            min(ordered_at) as first_order_at,
            max(ordered_at) as last_order_at
        from orders
        group by store_id
    )
select
    store_id,
    number_of_orders,
    total_order_amount,
    avg_order_amount,
    total_tax_paid,
    first_order_at,
    last_order_at
from store_orders
