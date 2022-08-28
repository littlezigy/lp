// Line of credit
type credit_delegates = (address, nat)map
type credit_delegator_data = {
    delegates: credit_delegates;
    buffer: nat;
}
type credit_delegator = credit_delegator_data

type credit_delegators = (address, credit_delegator_data) big_map

// Pool
type user_tokens = (address option, nat) map
type deposited_tokens = ((address, user_tokens) map) // map(user address, map(token address, amountn))

type token_utilization_permyriad = (address option, nat)map // None means token is tez
type credit_used = (address, nat)big_map

// Storage
type t = {
    deposited_tokens : deposited_tokens;
    token_utilization_permyriad: token_utilization_permyriad; // permyriad = 1/10,000;
    credit_used: credit_used;
    credit_delegators: credit_delegators
}
