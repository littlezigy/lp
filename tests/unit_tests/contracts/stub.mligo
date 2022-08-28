module Stub = struct
    type response = {
        string: string option;
        nat: nat option;
        int: int option;
    }

    type responses = (string, response)map
    type storage = responses
    let storage:storage = Map.empty

    let responses = (Map.empty: responses)

    let stub_function(type k) (fn_name, fn_value, _storage: string * k * storage option): storage =
        storage

    let get_response(key: string) : response =
        match Map.find_opt key responses with
            None -> { string = (None: string option);
                nat = (None: nat option);
                int = (None: int option);
            }
        | Some v -> v
end

let set_function_response_nat(fn_name, fn_value, _storage: string * nat * Stub.storage option): Stub.storage =
    let storage:Stub.storage = match _storage with
      None -> Map.empty
    | Some v -> v in

    storage
