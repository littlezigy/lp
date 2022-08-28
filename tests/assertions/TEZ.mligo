#import "utils.mligo" "UTILS"

let _fail_str = UTILS.fail_str
let _pass_str = UTILS.pass_str

let _to_be_equal (one, two : tez * tez) : nat =
    if one=two then let _ = Test.log("Test Passed") in 0n
    else 1n

module MUTEZ =
struct
    let to_be_equal (one, two : tez * tez) : nat =
        if one=two then let _ = Test.log("Test Passed") in 0n
        else
            let _ = Test.log(_fail_str, "Expected", one, "to be equal to", two) in
            1n

    let to_be_less_than (a, b : tez * tez) : nat =
        if a<b then 0n
        else
            // let fails = UTILS.fail_test() in
            let _ = Test.log(_fail_str, "expected", a, "to be less than", b) in
            1n
        
end

module TEZ =
struct
    let to_be_equal (one, two : tez * tez) : nat =
        let res = _to_be_equal(one, two) in
        let _ = if res = 1n then
            Test.log(_fail_str, "Expected", one, "to be equal to", two) in
        res


    let to_be_less_than (a, b : tez * tez) : nat =
        if a<b then 0n
        else
            // let fails = UTILS.fail_test() in
            let _ = Test.log(_fail_str, "expected", a, "to be less than", b) in
            1n
        
end
