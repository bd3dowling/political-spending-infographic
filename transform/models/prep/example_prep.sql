with example_prep as (
    select *
    from {{ ref("example_raw") }}
)

select * from example_prep
