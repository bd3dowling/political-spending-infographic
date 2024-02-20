-- noqa: disable=RF01,RF03,RF05
with subset_rename as (
    select
        "transaction.id" as contribution_id,
        date as contribution_date,
        amount as contribution_amount,
        cycle as election_cycle,
        "election.type" as election_type,
        seat as sought_seat,
        "bonica.cid" as contributor_id,
        "contributor.type" as contributor_type,
        "contributor.state" as contributor_state,
        "contributor.cfscore" as contributor_cf_score,
        "bonica.rid" as recipient_id,
        "recipient.type" as recipient_type,
        "recipient.party" as recipient_party,
        "recipient.state" as recipient_state,
        "candidate.cfscore" as recipient_cf_score
    from {{ source( 'warehouse', 'dime_contributions_2022' ) }}
),
-- noqa: enable=RF01,RF03,RF05

recast_clean as (
    select
        contribution_id,
        contribution_date::date as contribution_date,
        contribution_amount::int as contribution_amount,
        election_cycle::int as election_cycle,
        contributor_cf_score::float as contributor_cf_score,
        recipient_cf_score::float as recipient_cf_score,
        upper(contributor_state) as contributor_state,
        coalesce(recipient_id, 'unknown') as recipient_id,
        coalesce(contributor_id, 'unknown') as contributor_id,
        split_part(sought_seat, ':', 1) = 'federal' as election_is_federal,
        split_part(sought_seat, ':', 2) as election_seat_type,
        contributor_type = 'I' as contributor_is_individual,
        recipient_type = 'CAND' as recipient_is_candidate,
        {# Remap United States (President) to be DC -#}
        case
            when recipient_state = '00' then 'DC'
            else upper(recipient_state)
        end as recipient_state,
        case
            when election_type = 'P' then 'primary'
            when election_type = 'G' then 'general'
            else 'unknown'
        end as election_type,
        case
            when recipient_party = '100' then 'democrat'
            when recipient_party = '200' then 'republican'
            when recipient_party = '328' then 'independent'
            else 'unknown'
        end as recipient_party
    from subset_rename
)

select * from recast_clean
