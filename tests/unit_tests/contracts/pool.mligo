#import "../../../contracts/storage.mligo" "Storage"
#include "./stub.mligo"
#include "../../../contracts/pool.mligo"

type test_parameter = SupplyCollateral of parameter
    // | LoanLimit of address

let main((p, s): (test_parameter * Storage.t)) : return =
    match p with
    | SupplyCollateral v -> supply_collateral("tez", s)
    // | LoanLimit v -> get_loan_limit(v, s)
