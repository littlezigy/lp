(*
Borrow should return tokens equivalent to collateral deposited
Borrow should check whether user has enough collaterral
Reject if user does not have enought collateral
*)

(* ================================================================
 * Tests for borrow functions
 *)

let () = Test.reset_state 5n ([]: tez list)

let test_borrow_should_fail_if_user_tries_to_borrow_above_limit =
    let asserts : nat option = None in
    let user : address =  Test.nth_bootstrap_account 3 in

    let init_balance : tez = Test.get_balance user in
    let _ = Test.log "Init balance:" in
    let _ = Test.log init_balance in

    let storage = UTILS.borrow_storage() in
    (*
    // let res = Borrow.borrow_tez(50n, storage) in
    *)
    let (_, borrow_taddr, borrow) = UTILS.OriginateContract.borrow ("borrow_tez", (None: Borrow.Stub.storage option)) in

    let _ = Test.set_source user in
    let tx = Test.transfer_to_contract borrow (BorrowTez 50n: Borrow.parameter) 50tez in
    let _ = Test.log "transaction" in
    let _ = Test.log tx in

    let txFee : tez = match tx with
        | Fail _ -> 1mutez
        | Success n -> n * 1mutez in

    let expected_balance : tez = match init_balance - txFee with
        | None -> failwith "negative tez"
        | Some s -> s in

    let _ = Test.log "init balance minus transaction fee" in
    let _ = Test.log expected_balance in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.to_fail(tx)) in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.TEZ.to_be_equal(Test.get_balance user, expected_balance)
    ) in

    EXPECT.results asserts

let test_borrow_should_transfer_tez_if_enough_collateral =
    let asserts : nat option = None in
    let user : address =  Test.nth_bootstrap_account 3 in

    let init_balance : tez = Test.get_balance user in

    let stub_loan_limit_fn = 50n in

    let stub_storage = Borrow.Stub.set_function_response_nat("_get_loan_limit", 50n, (None: Borrow.Stub.storage option)) in

    let storage = UTILS.borrow_storage() in

    let (_, borrow_taddr, borrow) = UTILS.OriginateContract.borrow ("borrow_tez", (None: Stub.storage option)) in

    let _ = Test.log borrow in

    let _ = Test.set_source user in
    let tx = Test.transfer_to_contract borrow (BorrowTez 50n: Borrow.parameter) 50tez in

    let _ = Test.log tx in

    let txFee : tez = match tx with
        | Fail _ -> 1mutez
        | Success n -> n * 1mutez in

    let _ = Test.log("tx fee") in
    let _ = Test.log(tx) in

    let expected_balance : tez = match init_balance - txFee with
        | None -> failwith "negative tez"
        | Some s -> s in

    let _ = Test.log "init balance minus transaction fee" in
    let _ = Test.log expected_balance in

    let _ = Test.log("balance after transaction") in
    let _ = Test.log(Test.get_balance user) in

    let expected_balance : tez = expected_balance + 50tez in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.TEZ.to_be_equal(Test.get_balance user, expected_balance)
    ) in

    EXPECT.results asserts

