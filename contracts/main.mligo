#import "FA1.2.mligo" "FA1.2"

#import "storage.mligo" "Storage"
#import "_pool.mligo" "Pool"
#import "token.mligo" "LPToken"
#import "loc.mligo" "LOC"
#include "borrow.mligo"

type parameter =
    BorrowToken of borrow_token
  | BorrowTez of borrow_tez
  | RepayLoan of repay_loan
  | SupplyCollateral of Pool.supplyCollateralParameter
  | DepositToken of Pool.depositTokenParameter

  | AddDelegate of LOC.add_delegate
  | SetDelegateLimit of LOC.set_delegate_limit
  | RemoveDelegate of address

let main((p, s): (parameter * storage)) : return =
    match p with
        BorrowToken v -> borrow_token(v,s)
      | BorrowTez v -> borrow_tez(v,s)
      | RepayLoan v -> repay_loan(v,s)
      | SupplyCollateral v -> Pool.supply_collateral(v,s)
      | DepositToken v -> Pool.deposit_token(v,s)

      | AddDelegate v -> LOC.add_delegate(v,s)
      | RemoveDelegate v -> LOC.remove_delegate(v,s)
      | SetDelegateLimit v -> LOC.set_delegate_limit(v,s)
