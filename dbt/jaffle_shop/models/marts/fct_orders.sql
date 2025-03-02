{{ config(materialized="table") }}

select order_id, customer_id, store_id, subtotal, tax_paid, order_total, ordered_at
from {{ ref("stg_jaffle_shop__orders") }}
