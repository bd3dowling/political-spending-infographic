select *
from {{ source( 'warehouse', 'dime_2022_raw' ) }}
