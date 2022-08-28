#import "../../contracts/storage.mligo" "Storage"
#import "./contracts/stub.mligo" "Stub"
#import "./contracts/borrow.mligo" "Borrow"
#import "./contracts/pool.mligo" "Pool"

let borrow_storage() : Storage.t =
    let storage : Borrow.storage = {
        deposited_tokens = (Map.empty: Storage.deposited_tokens);
        token_utilization_permyriad = (Map.empty: Storage.token_utilization_permyriad);
    }
    in
    storage

module OriginateContract =
struct
    let borrow(entrypoint, stubs : string * Borrow.Stub.storage option) : address * (Borrow.parameter, Borrow.storage)typed_address * (Borrow.parameter)contract =
        let storageCompiler = fun(x: Borrow.storage) -> x in
        let storage : Borrow.storage = borrow_storage() in

        let (addr, _, _) = Test.originate_from_file "tests/unit/contracts/borrow.mligo" "main" ([]: string list) (Test.run storageCompiler storage) 0tez in
        let taddr : (Borrow.parameter, Borrow.storage)typed_address = Test.cast_address(addr) in
        let contract = Test.to_contract taddr in

        let () = match stubs with
          None -> ()
        | Some v ->
            // let _ = Test.transfer_to_contract borrow
            () in

        (addr, taddr, contract)

    let pool(storage_opt : Pool.storage option) : address * (Pool.parameter, Pool.storage)typed_address * (Pool.parameter)contract =
        let storageCompiler = fun(x: Pool.storage) -> x in
        let storage : Pool.storage = {
            deposited_tokens = (Map.empty : Pool.Storage.deposited_tokens);
            token_utilization_permyriad = (Map.empty : Pool.Storage.token_utilization_permyriad);
        }
        in

        let (addr, _, _) = Test.originate_from_file "tests/unit/contracts/pool.mligo" "main" ([]: string list) (Test.run storageCompiler storage) 0tez in
        let taddr : (Pool.parameter, Pool.storage)typed_address = Test.cast_address(addr) in
        let contract = Test.to_contract taddr in
        (addr, taddr, contract)
end
