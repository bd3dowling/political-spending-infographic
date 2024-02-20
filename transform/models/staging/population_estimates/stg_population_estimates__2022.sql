{# Territory population estimates not available directly from census (AS, GU, VI) -#}
{# Retrieved manually via https://data.worldbank.org/country/{CODE} #}
{% set territory_estimates = [
    {
        "state_id": 60,
        "population_estimate": 44273
    },
    {
        "state_id": 66,
        "population_estimate": 171774
    },
    {
        "state_id": 78,
        "population_estimate": 105413
    },
] %}

with select_rename_cast as (
    select
        2022 as estimate_year,
        state::int as state_id,
        popestimate2022 as population_estimate
    from {{ ref('census_2020_populations') }}
    union all
    -- Manually add estiamtes for AS, GU, VI
    {% for territory_estimate in territory_estimates %}
        select
            2022 as estimate_year,
            {{ territory_estimate.state_id }} as state_id,
            {{ territory_estimate.population_estimate }} as population_estimate
        {{ "union all" if not loop.last }}
    {% endfor %}
)

select *
from select_rename_cast
{# Exclude regional/multi-state estimates -#}
where state_id > 0
