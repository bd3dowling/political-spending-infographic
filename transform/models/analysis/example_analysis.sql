with example_analysis as (
    select *
    from {{ ref( "example_prep" ) }}
)

select * from example_analysis
