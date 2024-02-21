{# For directly filtering out states in which there was no senate race -#}
{% set senate_states = [
  "AL",
  "AK",
  "AZ",
  "AK",
  "CA",
  "CO",
  "CN",
  "FL",
  "GA",
  "HI",
  "ID",
  "IL",
  "IN",
  "IA",
  "KS",
  "KY",
  "LA",
  "MD",
  "MO",
  "NV",
  "NH",
  "NY",
  "NC",
  "ND",
  "OH",
  "OK",
  "OR",
  "PA",
  "SC",
  "SD",
  "UT",
  "VT",
  "WA",
  "WI"
] -%}

with roll_up_filter as (
    select
        contribution_date,
        contributor_is_individual,
        contributor_state,
        recipient_state as candidate_state,
        recipient_party as candidate_party,
        sum(contribution_amount) as contribution_amount
    from {{ ref('contributions') }}
    where
        election_is_federal
        and election_type = 'general'
        and election_seat_type = 'senate'
        and candidate_party in ('democrat', 'republican')
        and contribution_date > '0000-01-01'
        and recipient_state not in ({{ "'" + senate_states|join("','") + "'" }})
    group by all
)

select
    contribution_date,
    contributor_is_individual,
    contributor_state,
    candidate_state,
    candidate_party,
    contribution_amount
from roll_up_filter as contributions
