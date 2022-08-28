#import "./pool.mligo" "Pool"
#import "../../../contracts/storage.mligo" "Storage"
#include "../../../contracts/borrow.mligo"
#include "./stub.mligo"

module Pool = struct
    let _get_loan_limit(user, storage: address * storage) : nat =
    let _stub_response = Stub.get_response "_get_loan_limit" in
    match _stub_response.nat with 
      None -> 0n
    | Some v -> v
end

type parameter = BorrowTez of borrowTezParameter | BorrowToken of borrowTokenParameter

let main(p, s: parameter * storage) : return =
    match p with
    | BorrowTez b -> borrow_tez(b,s)
    | BorrowToken b -> borrow_token(b,s)
