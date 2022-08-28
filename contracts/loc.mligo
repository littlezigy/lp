// Line of credit
#import "storage.mligo" "Storage"

type storage = Storage.t

type return = operation list * storage

let default_buffer = 30n

// Credit
// buffer: How close to borrow limit to stop borrowers so collateral is safe
// loc percentage: percentage of supplied tokens that borrowers can borrow.
// If borrowers have not borrowed up to loc percentage, but buffer has been reached, borrowers will not be able to borrow any more from this line of credit.

let get_delegator(delegator, s: address * storage): Storage.credit_delegator_data =
    match Big_map.find_opt delegator s.credit_delegators with
        None -> {delegates=(Map.empty: Storage.credit_delegates); buffer=default_buffer}
      | Some v -> v

let update_delegator ((delegator_address, data), s: (address * Storage.credit_delegator) * storage) : storage =  
    let delegators:Storage.credit_delegators = Big_map.update delegator_address (Some(data)) s.credit_delegators in
    { s with credit_delegators = delegators }

let add_delegator ((delegator_address, data), s: (address * Storage.credit_delegator) * storage) : storage =  
    let delegators = Big_map.add delegator_address data s.credit_delegators in
    { s with credit_delegators = delegators }

let save_delegator((delegator_address, data), s: (address * Storage.credit_delegator) * storage) : storage =  
    match Big_map.find_opt delegator_address s.credit_delegators with
        Some _ -> update_delegator((delegator_address, data), s)
      | None -> add_delegator((delegator_address, data), s)

    // let s = { s with credit_delegators = save_delegator((delegator_addr, delegator), s) } in
      // in s

type add_delegate = address
let add_delegate(delegate, s: add_delegate * storage) : return =
    let operations: operation list = [] in
    let amount = 0n in

    let delegator_addr = Tezos.get_sender() in
    let delegator: Storage.credit_delegator = get_delegator(delegator_addr, s) in

    let delegates: Storage.credit_delegates = match Map.find_opt delegate delegator.delegates with
        None -> Map.add delegate amount delegator.delegates
      | Some v -> delegator.delegates in

    let delegator = { delegator with delegates = delegates } in
    let s:storage = save_delegator((delegator_addr, delegator), s) in

    operations, s

type set_delegate_limit = address * nat
let set_delegate_limit((delegate, limit), s: set_delegate_limit * storage): return =
    let delegator_addr = Tezos.get_sender() in
    let delegator: Storage.credit_delegator = get_delegator(delegator_addr, s) in

    let delegates: Storage.credit_delegates = match Map.find_opt delegate delegator.delegates with
        Some _ -> Map.update delegate (Some(limit)) delegator.delegates
      | None -> delegator.delegates in

    let delegator = { delegator with delegates = delegates } in
    let s:storage = save_delegator((delegator_addr, delegator), s) in

    ([]: operation list), s

let remove_delegate(delegate, s: address * storage): return =
    let operations: operation list = [] in

    let delegator_addr = Tezos.get_sender() in
    let delegator: Storage.credit_delegator = get_delegator(delegator_addr, s) in

    let delegates: Storage.credit_delegates = match Map.find_opt delegate delegator.delegates with
        Some _ -> Map.remove delegate delegator.delegates
      | None -> delegator.delegates in

    let delegator = { delegator with delegates = delegates } in
    let s:storage = save_delegator((delegator_addr, delegator), s) in

    operations, s
