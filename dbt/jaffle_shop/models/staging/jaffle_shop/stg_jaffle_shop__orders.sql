select
    id as order_id,
    customer as customer_id,
    store_id,
    subtotal,
    tax_paid,
    order_total,
    cast(ordered_at as date) as ordered_date,
    ordered_at
from {{ source("jaffle_shop", "orders") }}
