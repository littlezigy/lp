(*
Line of credit tests
*)

let () = Test.reset_state 5n ([]: tez list)

let test_add_delegate =
    let asserts : nat option = None in
    let user = Test.nth_bootstrap_account 1 in
    let delegator = user in
    let delegate1 = Test.nth_bootstrap_account 3 in
    let delegate2 = Test.nth_bootstrap_account 4 in

    let (_,lprotocol_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol((None: LP.Storage.t option), ([]: string list)) in

    // Add credit delegates
    let tx_opt = Test.transfer_to_contract lprotocol
        (AddDelegate delegate1: LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    let tx_opt = Test.transfer_to_contract lprotocol
        (AddDelegate delegate2: LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in

    // Check that delegates have been stored in map
    let storage = Test.get_storage lprotocol_taddr in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.BIG_MAP.to_have_key(delegator, storage.credit_delegators)) in

    let delegator: LP.Storage.credit_delegator_data = match Big_map.find_opt delegator storage.credit_delegators with
        None -> UTILS.empty_credit_delegator()
      | Some v -> v in

    let delegates: LP.Storage.credit_delegates = delegator.delegates in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key(delegate1, delegates)) in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key(delegate2, delegates)) in

    EXPECT.results asserts

let test_remove_delegate =
    let asserts : nat option = None in
    let delegator_addr = Test.nth_bootstrap_account 1 in

    let delegate1 = Test.nth_bootstrap_account 3 in
    let delegate2 = Test.nth_bootstrap_account 4 in
    let delegate3 = Test.nth_bootstrap_account 2 in

    let delegator_data = UTILS.empty_credit_delegator() in
    let delegator_data = { delegator_data with delegates = Map.literal[
        (delegate1, 3n);
        (delegate2, 7n);
        (delegate3, 9n);
    ]} in

    let delegators: LP.Storage.credit_delegators = Big_map.literal[
        (delegator_addr, delegator_data)
    ] in

    let init_storage = UTILS.lending_protocol_storage() in
    let init_storage = { init_storage with credit_delegators = delegators } in

    let (_,lprotocol_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol(Some(init_storage), ([]: string list)) in

    let tx_opt = Test.transfer_to_contract lprotocol
        (RemoveDelegate delegate1: LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in
    let tx_opt = Test.transfer_to_contract lprotocol
        (RemoveDelegate delegate2: LendingProtocol.parameter) 0tez in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.not_to_fail(tx_opt)) in


    let storage = Test.get_storage lprotocol_taddr in
    let delegator: LP.Storage.credit_delegator_data = match Big_map.find_opt delegator_addr storage.credit_delegators with
        None -> UTILS.empty_credit_delegator()
      | Some v -> v in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_not_have_key(delegate1, delegator.delegates)) in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_not_have_key(delegate2, delegator.delegates)) in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key(delegate3, delegator.delegates)) in

    EXPECT.results asserts

let test_set_delegate_limit =
    let asserts : nat option = None in
    let delegator_addr = Test.nth_bootstrap_account 1 in

    let delegate1 = Test.nth_bootstrap_account 3 in
    let delegate2 = Test.nth_bootstrap_account 4 in
    let delegate3 = Test.nth_bootstrap_account 2 in

    let delegator_data = UTILS.empty_credit_delegator() in
    let delegator_data = { delegator_data with delegates = Map.literal[
        (delegate1, 3n);
        (delegate2, 0n);
        (delegate3, 9n);
    ]} in

    let delegators: LP.Storage.credit_delegators = Big_map.literal[
        (delegator_addr, delegator_data)
    ] in

    let init_storage = UTILS.lending_protocol_storage() in
    let init_storage = { init_storage with credit_delegators = delegators } in

    let (_,lprotocol_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol(Some(init_storage), ([]: string list)) in

    let tx_opt = Test.transfer_to_contract lprotocol
        (SetDelegateLimit (delegate2, 13n): LendingProtocol.parameter) 0tez in
    let tx_opt = Test.transfer_to_contract lprotocol
        (SetDelegateLimit (delegate3, 5n): LendingProtocol.parameter) 0tez in

    let storage = Test.get_storage lprotocol_taddr in
    let delegator: LP.Storage.credit_delegator_data = match Big_map.find_opt delegator_addr storage.credit_delegators with
        None -> UTILS.empty_credit_delegator()
      | Some v -> v in

    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key_value(delegate1, 3n, delegator.delegates)) in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key_value(delegate2, 13n, delegator.delegates)) in
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.MAP.to_have_key_value(delegate3, 5n, delegator.delegates)) in

    EXPECT.results asserts

let test_set_loc_buffer =
    let asserts : nat option = None in
    let buffer = 3700n in

    let delegator_addr = Test.nth_bootstrap_account 1 in

    let delegator_data = UTILS.empty_credit_delegator() in
    let delegator_data = { delegator_data with buffer = buffer } in

    let (_,lprotocol_taddr,lprotocol) = UTILS.OriginateContract.lending_protocol((None: LP.Storage.t option), ([]: string list)) in

    let storage = Test.get_storage lprotocol_taddr in
    let delegator: LP.Storage.credit_delegator_data = match Big_map.find_opt delegator_addr storage.credit_delegators with
        None -> UTILS.empty_credit_delegator()
      | Some v -> v in

    (*
    let asserts = EXPECT.add_assert(asserts,
        EXPECT.NAT.to_be_equal(delegator.buffer, buffer)) in
    *)

    EXPECT.results asserts

let test_set_max_loc_percent = // Percent of pool to allow borrowers (ie delegates) borrow from. If 50%, borrowers can only borrow up to 50% of creditors loan limit
    let asserts : nat option = None in
    EXPECT.results asserts
