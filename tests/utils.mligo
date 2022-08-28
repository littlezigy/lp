#import "../contracts/main.mligo" "LP"
#import "../contracts/FA1.2.mligo" "FA1_2"

let fa1_2_storage(): FA1_2.Storage.t =
    let storage: FA1_2.Storage.t = {
        ledger = (Big_map.empty: FA1_2.Ledger.t);
        token_metadata = {token_id=3n; token_info = (Map.empty: (string,bytes)map)};
        totalSupply = 0n;
    } in
    storage

let lending_protocol_storage(): LP.Storage.t =
    let storage: LP.Storage.t = {
        deposited_tokens = (Map.empty: LP.Storage.deposited_tokens);
        token_utilization_permyriad = (Map.empty: LP.Storage.token_utilization_permyriad);
        credit_used = (Big_map.empty: LP.Storage.credit_used);
        credit_delegators = (Big_map.empty: LP.Storage.credit_delegators);
    }
    in storage

let empty_credit_delegator(): LP.Storage.credit_delegator_data =
    {
        delegates = (Map.empty: LP.Storage.credit_delegates);
        buffer = 0n
    }
