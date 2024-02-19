select *
from {{ source( 'dime', 'dime' ) }}
