{{ config(materialized="table") }}

with
    customers as (select * from {{ ref("stg_jaffle_shop__customers") }}),
    customer_orders as (select * from {{ ref("int_customer_orders_aggregated") }}),
    order_freq as (select * from {{ ref("int_customer_orders_ordered") }}),
    final as (
        select
            customers.customer_id,
            customers.customer_name,
            customer_orders.first_order_at,
            customer_orders.last_order_at,
            customer_orders.last_ordered_date,
            coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
            coalesce(customer_orders.total_order_amount, 0) as total_order_amount,
            coalesce(customer_orders.avg_order_amount, 0) as avg_order_amount,
            coalesce(customer_orders.min_order_value, 0) as min_order_value,
            coalesce(customer_orders.max_order_value, 0) as max_order_value,
            coalesce(order_freq.order_frequency, 0) as avg_days_between_orders
        from customers
        left join customer_orders using (customer_id)
        left join order_freq using (customer_id)
    )
select
    customer_id,
    customer_name,
    first_order_at,
    last_order_at,
    number_of_orders,
    total_order_amount,
    avg_order_amount,
    min_order_value,
    max_order_value,
    avg_days_between_orders,
    current_date - last_ordered_date as days_since_last_order
from final
