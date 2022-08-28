#import "FA1.2.mligo" "FA1_2"

let transfer_token(from, to, token, amount: address * address * address * nat): operation =
    let token_contract: (FA1_2.parameter)contract = Tezos.get_contract_with_error token "Not an FA1.2" in
    Tezos.transaction (Transfer (from, (to, amount)) : FA1_2.parameter) 0tez token_contract

let transfer_token_to_user(user, token_addr, amount : address * address * nat): operation =
    transfer_token(Tezos.get_self_address(), user, token_addr, amount)

let transfer_token_from_user(user, token_addr, amount: address * address * nat): operation =
    transfer_token(user, Tezos.get_self_address(), token_addr, amount)

let transfer_tez(user, amount: address * tez): operation =
    let receiver : (unit)contract = Tezos.get_contract_with_error user "Not a wallet" in
    Tezos.transaction () amount receiver

