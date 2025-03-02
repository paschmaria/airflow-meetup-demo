{{ config(materialized="ephemeral") }}

with
    order_freq as (
        select
            customer_id,
            ordered_date,
            ordered_date - lag(ordered_date) over (
                partition by customer_id order by ordered_date
            ) as days_between
        from {{ ref("stg_jaffle_shop__orders") }}
    )

select customer_id, avg(days_between) as order_frequency
from order_freq
where days_between is not null
group by customer_id
