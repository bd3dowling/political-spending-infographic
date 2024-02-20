with population_estimates_2022 as (
    select
        stg_pop_ests_2022.estimate_year,
        state_codes.state_code,
        stg_pop_ests_2022.population_estimate
    from {{ ref('stg_population_estimates__2022') }} as stg_pop_ests_2022
    inner join {{ ref('state_codes') }} as state_codes on
        state_codes.state_id = stg_pop_ests_2022.state_id
)

select * from population_estimates_2022
