#import "FA1.2.mligo" "FA1_2"
type storage = Storage.t
type token_address = string
type token = address option
type parameter = string

type return = operation list * storage

let _get_loan_limit(user, storage: address * storage) : nat =
    let user_tokens : Storage.user_tokens = match Map.find_opt user storage.deposited_tokens with
        Some v -> v
      | None -> (Map.empty: Storage.user_tokens) in

    let _loan_limit = 0n in
    let calc_loan_limit (limit, (token_addr, num_tokens) : nat * (address option * nat)) : nat =
        let token_util = match Map.find_opt token_addr storage.token_utilization_permyriad with
          None -> 0n
        | Some v -> v * num_tokens in

        let token_util = token_util / 10_000n in
        limit + token_util in

    Map.fold calc_loan_limit user_tokens 0n

let get_loan_limit(user, storage: address * storage) : nat =
    _get_loan_limit(user, storage)

let calculate_earned_interest() : nat =
    0n

let calculate_loan_interest(): nat =
    0n

// let transfer_token(token_addr, amount: address * nat) : operation =

type depositTokenParameter = (token * nat)
let deposit_token((deposit_details, storage) : (depositTokenParameter * storage)) : return =
    let operations: operation list = [] in

    let depositor : address = Tezos.get_sender() in
    let (supply_token,token_amount) = if Tezos.get_amount() > 0mutez
        then (None, Tezos.get_amount() / 1mutez: token * nat) 
        else let _ = match deposit_details.0 with
              Some v -> v
            | None -> failwith "token address cannot be none" in
        deposit_details in

    let user_tokens = match Map.find_opt depositor storage.deposited_tokens with
        | Some m -> m
        | None -> (Map.empty: Storage.user_tokens) in

    let total_collateral : nat = token_amount in

    let user_tokens = Map.add supply_token total_collateral user_tokens in

    let deposited_tokens =
        Map.add depositor (user_tokens)
         storage.deposited_tokens in

    let storage = {
        storage with deposited_tokens = deposited_tokens
    } in

    let operations = match supply_token with 
        None -> operations
      | Some _token ->
        let token_contract: (FA1_2.parameter)contract = Tezos.get_contract_with_error _token "Not an FA1.2" in
        let operations : operation list = Tezos.transaction (Transfer (depositor, (Tezos.get_self_address(), token_amount)) : FA1_2.parameter) 0tez token_contract :: operations in
        operations in

    operations, storage

type supplyCollateralParameter = depositTokenParameter
let supply_collateral((token, storage) : (supplyCollateralParameter * storage)) : return =
    deposit_token(token, storage)
