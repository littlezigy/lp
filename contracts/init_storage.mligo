let init_storage = {
    deposited_tokens = (Map.empty: deposited_tokens);
    token_utilization_permyriad = (Map.empty: token_utilization_permyriad); // permyriad = 1/10,000;
    credit_used: (Big_map.empty: credit_used);
    credit_delegators: (Big_map.empty: credit_delegators);
}
in init init
