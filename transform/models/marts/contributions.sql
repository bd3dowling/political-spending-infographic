with dime_contributions_1980 as (
    select
        contribution_id,
        contribution_date,
        contribution_amount,
        election_cycle,
        election_type,
        election_is_federal,
        election_seat_type,
        contributor_id,
        contributor_is_individual,
        contributor_state,
        contributor_cf_score,
        recipient_id,
        recipient_is_candidate,
        recipient_party,
        recipient_state,
        recipient_cf_score
    from {{ ref('stg_dime__contributions_1980') }}
)

select * from dime_contributions_1980
