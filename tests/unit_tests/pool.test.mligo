(*
Borrow should return tokens equivalent to collateral deposited
Borrow should check whether user has enough collaterral
Reject if user does not have enought collateral
*)

(* ================================================================
 * Tests for borrow functions
 *)

let () = Test.reset_state 5n ([]: tez list)

let test_loan_limit_should_be_sum_of_collaterizable_portion_of_deposited_tokens =
    let asserts : nat option = None in

    let user = Test.nth_bootstrap_account 4 in

    let token1 = Test.nth_bootstrap_contract 1n in
    let token2 = Test.nth_bootstrap_contract 2n in
    let token3 = Test.nth_bootstrap_contract 3n in

    let storage : Pool.storage = {
        deposited_tokens = Map.literal[
            (user,
                Map.literal[
                    (Some(token1), 1000n);
                    (Some(token2), 6000n);
                    (Some(token3), 8000n)
                ]
            )
        ];
        token_utilization_permyriad = Map.literal[
            (Some(token1), 8500n);
            (Some(token2), 7500n);
            (Some(token3), 6200n);
        ];
    } in

    let (_, pool_taddr, pool) = UTILS.OriginateContract.pool(Some(storage)) in

    let loan_limit = Pool.get_loan_limit(user, storage) in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.NAT.to_be_equal(loan_limit, 10310n)
    ) in

    EXPECT.results asserts


let test_supply_collateral_should_add_sender_to_deposited_tokens =
    let asserts : nat option = None in

    let sender : address =  Test.nth_bootstrap_account 1 in

    let (_, pool_taddr, pool) = UTILS.OriginateContract.pool(None: Pool.storage option) in

    let _ = Test.transfer_to_contract pool "blah" 0tez in
    let storage = Test.get_storage pool_taddr in

    let _ = Test.log(storage) in
    let asserts = EXPECT.add_assert(asserts, EXPECT.MAP.to_have_key(sender, storage.deposited_tokens)) in

    EXPECT.results asserts

let test_supply_collateral_should_add_sender_tokens_deposited_tokens =
    let asserts : nat option = None in

    let sender : address =  Test.nth_bootstrap_account 1 in

    let (_, pool_taddr, pool) = UTILS.OriginateContract.pool (None: Pool.storage option) in

    let _ = Test.transfer_to_contract pool "blah" 5tez in
    let storage = Test.get_storage pool_taddr in

    let _ = Test.log(storage) in
    // let asserts = EXPECT.add_assert(asserts, EXPECT.MAP.to_have_key_of_value(sender, 5000000n, storage.deposited_tokens)) in

    EXPECT.results asserts
