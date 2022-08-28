(*
Borrow should return tokens equivalent to collateral deposited
Borrow should check whether user has enough collaterral
Reject if user does not have enought collateral
*)

(* ================================================================
 * Tests for borrow functions
 *)

let test_deposit_tez_into_pool =
    let asserts : nat option = None in
    let user = Test.nth_bootstrap_account 1 in

    let (_,lprotocol_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol((None: LP.Storage.t option), ([]: string list)) in

    let tx_opt = Test.transfer_to_contract lprotocol
        (SupplyCollateral ((None, 0n): LendingProtocol.Pool.supplyCollateralParameter): LendingProtocol.parameter)
        50tez in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let storage = Test.get_storage lprotocol_taddr in
    let user_tokens: LP.Storage.user_tokens = match Map.find_opt user storage.deposited_tokens with
        None -> failwith "empty map"
      | Some v -> v in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key_value((None: address option), 50_000_000n, user_tokens)) in

    EXPECT.results asserts

let test_deposit_token_into_pool =
    let asserts : nat option = None in
    let user = Test.nth_bootstrap_account 1 in

    let init_token_storage = UTILS.fa1_2_storage() in
    let ledger: FA1_2.Ledger.t = Big_map.literal[
        (user, (200n, (Map.empty: FA1_2.Allowance.t)) )
    ] in

    let init_token_storage = { init_token_storage with ledger = ledger } in
    let (token_addr,token_taddr,token_contract) = UTILS.OriginateContract.fa1_2(Some(init_token_storage)) in

    let token_amount = 120n in

    let (lprotocol_addr,lprotocol_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol((None: LP.Storage.t option), ([]: string list)) in

    // Approve token
    let _ = Test.transfer_to_contract_exn token_contract (Approve (lprotocol_addr, token_amount): FA1_2.parameter) 0tez in

    let tx_opt = Test.transfer_to_contract lprotocol
        (DepositToken ((Some(token_addr), token_amount): LendingProtocol.Pool.depositTokenParameter): LendingProtocol.parameter)
        0tez in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let storage = Test.get_storage lprotocol_taddr in
    let user_tokens: LP.Storage.user_tokens = match Map.find_opt user storage.deposited_tokens with
        None -> failwith "empty map"
      | Some v -> v in

    let token_storage = Test.get_storage token_taddr in

    let lp_balance = match Big_map.find_opt lprotocol_addr token_storage.ledger with
        None -> 0n
      | Some v -> v.0 in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.NAT.to_be_equal(lp_balance, token_amount)) in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key_value((Some(token_addr)), token_amount, user_tokens)) in

    EXPECT.results asserts

let test_borrow_tez =
    let asserts : nat option = None in

    let storage = UTILS.lending_protocol_storage() in
    let storage = { storage with token_utilization_permyriad = Map.literal[
        ( (None: address option), 10000n)
    ]} in

    let (_,_,lprotocol) = UTILS.OriginateContract.lending_protocol(Some(storage), ([]: string list)) in

    let tx_opt = Test.transfer_to_contract lprotocol (DepositToken ((None, 0n): LendingProtocol.Pool.depositTokenParameter): LendingProtocol.parameter) 50tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let tx_opt = Test.transfer_to_contract lprotocol (BorrowTez 50n: LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    EXPECT.results asserts

let test_borrow_token_and_repay_loan =
    let asserts : nat option = None in

    let borrow_amount = 55n in
    let user = Test.nth_bootstrap_account 1 in

    let storage = UTILS.lending_protocol_storage() in
    let storage = { storage with token_utilization_permyriad = Map.literal[
        ( (None: address option), 10000n)
    ]} in

    let _ = Test.set_source user in
    let (lp_addr,lp_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol(Some(storage), ([]: string list)) in

    let init_token_storage = UTILS.fa1_2_storage() in
    let ledger: FA1_2.Ledger.t = Big_map.literal[
        (lp_addr, (200n, (Map.empty: FA1_2.Allowance.t)) )
    ] in

    let init_token_storage = { init_token_storage with ledger = ledger } in
    let (token_addr,token_taddr,token_contract) = UTILS.OriginateContract.fa1_2(Some(init_token_storage)) in

    let tx_opt = Test.transfer_to_contract lprotocol (DepositToken ((None, 0n): LendingProtocol.Pool.depositTokenParameter): LendingProtocol.parameter) 50tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let tx_opt = Test.transfer_to_contract lprotocol (BorrowToken (token_addr,borrow_amount): LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let token_storage = Test.get_storage token_taddr in

    let user_balance = match Big_map.find_opt user token_storage.ledger with
        None -> 0n
      | Some v -> v.0 in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.NAT.to_be_equal(user_balance, borrow_amount)) in

    let lp_storage = Test.get_storage lp_taddr in

    let user_credit_used: nat = match Big_map.find_opt user lp_storage.credit_used with
        None -> 0n
      | Some v -> v in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.NAT.to_be_equal(user_credit_used, borrow_amount)
    ) in

    let repay_amount = 30n in
    let tx_opt = Test.transfer_to_contract lprotocol (RepayLoan ((Some(token_addr), repay_amount): LendingProtocol.Pool.depositTokenParameter): LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.NAT.to_be_equal(user_credit_used, abs(borrow_amount - repay_amount))) in

    EXPECT.results asserts

let test_repay_loan =
    let asserts : nat option = None in

    EXPECT.results asserts

let test_withdraw =
    let asserts : nat option = None in

    EXPECT.results asserts
