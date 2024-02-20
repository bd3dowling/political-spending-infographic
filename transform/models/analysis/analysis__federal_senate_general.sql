with roll_up_filter as (
    select
        contribution_date,
        contributor_is_individual,
        contributor_state,
        recipient_state as candidate_state,
        sum(contribution_amount) as contribution_amount
    from {{ ref('contributions') }}
    where
        election_is_federal
        and election_type = 'general'
        and election_seat_type = 'senate'
        and recipient_party in ('democrat', 'republican')
    group by all
)

select
    contributions.contribution_date,
    contributions.contributor_is_individual,
    contributions.contributor_state,
    contributions.candidate_state,
    contributions.contribution_amount as contribution_amount,
    contributor_state_populations.population_estimate as contributor_state_population,
    candidate_state_populations.population_estimate as candidate_state_population,
    divide(
        contribution_amount,
        contributor_state_population
    ) as contributor_state_normalised_contribution_amount,
    divide(
        contribution_amount,
        candidate_state_population
    ) as candidate_state_normalised_contribution_amount
from roll_up_filter as contributions
left join {{ ref('state_populations') }} as contributor_state_populations
    on contributions.contributor_state = contributor_state_populations.state_code
left join {{ ref('state_populations') }} as candidate_state_populations
    on contributions.candidate_state = candidate_state_populations.state_code
