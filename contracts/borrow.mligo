(*
*)

#include "transfers.mligo"
type storage = Storage.t
type return = operation list * storage

// Can overload function? No
// Get amount sent to contract? Tezos.get_amount

let get_credit_used(user, s: address * storage): nat =
    match Big_map.find_opt user s.credit_used with
        None -> 0n
      | Some v -> v

let set_credit_used((user, amount), s: (address * nat) * storage): storage =
    let credit_used_map: Storage.credit_used = match Big_map.find_opt user s.credit_used with
        None -> Big_map.add user amount s.credit_used
      | Some _ -> Big_map.update user (Some(amount)) s.credit_used in

    { s with credit_used = credit_used_map }

let increase_credit_used((user, amount), s: (address * nat) * storage): storage =
    let credit_used = get_credit_used(user, s) in

    set_credit_used((user, credit_used + amount), s)

let decrease_credit_used((user, amount), s: (address * nat) * storage): storage =
    let credit_used = get_credit_used(user, s) in

    let credit_used = credit_used - amount in
    let credit_used = if credit_used < 0 then 0n else abs(credit_used) in

    set_credit_used((user, credit_used), s)

type borrow_tez = nat
let borrow_tez(amount,s : borrow_tez * storage) : return =
    let operations : operation list = [] in
    let _amount = amount * 1mutez in
    let user = Tezos.get_sender() in 

    let s = increase_credit_used((user, amount), s) in

    let receiver : (unit)contract = Tezos.get_contract_with_error user "Not a wallet" in
    let operations : operation list = if Pool._get_loan_limit(user, s) > 0n 
        then Tezos.transaction () _amount receiver :: operations
        else failwith "Loan limit is too low for the amount you are trying to borrow" in

    operations, s

type borrow_token = (address * nat)
let borrow_token((token, amount), s: borrow_token * storage) : return =
    let operations : operation list = [] in
    let user = Tezos.get_sender() in 

    let s = increase_credit_used((user, amount), s) in

    let user = Tezos.get_sender() in
    let operations: operation list = transfer_token_to_user(user, token, amount) :: operations in

    operations, s

type repay_loan = (address option * nat)
let repay_loan((token_opt, amount),s: repay_loan * storage) : return =
    let operations : operation list = [] in
    let user = Tezos.get_sender() in 

    let s = increase_credit_used((user, amount), s) in

    let user = Tezos.get_sender() in
    let operations: operation list = match token_opt with 
        Some token -> transfer_token_from_user(user, token, amount) :: operations
      | None -> operations  in

    ([]: operation list), s
