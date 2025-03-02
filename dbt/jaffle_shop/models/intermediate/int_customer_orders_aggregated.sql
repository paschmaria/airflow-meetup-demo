{{ config(materialized="ephemeral") }}

with
    orders as (select * from {{ ref("stg_jaffle_shop__orders") }}),
    customer_orders as (
        select
            customer_id,
            min(ordered_date) as first_order_at,
            max(ordered_date) as last_order_at,
            count(order_id) as number_of_orders,
            sum(order_total) as total_order_amount,
            avg(order_total) as avg_order_amount,
            min(order_total) as min_order_value,
            max(order_total) as max_order_value,
            max(ordered_date) as last_ordered_date
        from orders
        group by customer_id
    )
select
    customer_id,
    number_of_orders,
    total_order_amount,
    avg_order_amount,
    min_order_value,
    max_order_value,
    first_order_at,
    last_order_at,
    last_ordered_date
from customer_orders
