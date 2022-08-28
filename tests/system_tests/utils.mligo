#import "../../contracts/FA1.2.mligo" "FA1_2"
#import "./contracts/lending_protocol.mligo" "LendingProtocol"
#include "../utils.mligo"

module OriginateContract =
struct
    let lending_protocol(storage, views: LendingProtocol.storage option * string list) : address * (LendingProtocol.parameter, LendingProtocol.storage)typed_address * (LendingProtocol.parameter)contract =
        let storageCompiler = fun(x: LendingProtocol.storage) -> x in
        let storage : LendingProtocol.storage = match storage with
            None -> lending_protocol_storage()
          | Some v -> v in

        let (addr, _, _) = Test.originate_from_file "tests/system_tests/contracts/lending_protocol.mligo" "main" ([]: string list) (Test.run storageCompiler storage) 0tez in
        let taddr : (LendingProtocol.parameter, LendingProtocol.storage)typed_address = Test.cast_address(addr) in
        let contract = Test.to_contract taddr in

        (addr, taddr, contract)

    let fa1_2(storage: FA1_2.storage option) : address * (FA1_2.parameter, FA1_2.storage)typed_address * (FA1_2.parameter)contract =
        let storageCompiler = fun(x: FA1_2.storage) -> x in
        let storage : FA1_2.storage = match storage with 
            None -> fa1_2_storage()
          | Some v -> v in

        let (addr, _, _) = Test.originate_from_file "contracts/FA1.2.mligo" "main" ([]: string list) (Test.run storageCompiler storage) 0tez in
        let taddr: (FA1_2.parameter, FA1_2.storage)typed_address = Test.cast_address(addr) in
        let contract = Test.to_contract taddr in

        (addr, taddr, contract)
end
