#import "../assertions/index.mligo" "EXPECT"
#import "../../contracts/FA1.2.mligo" "FA1_2"
#import "./contracts/lending_protocol.mligo" "LendingProtocol"
module LP = LendingProtocol

#import "./utils.mligo" "UTILS"

#include "pool.test.mligo"
#include "loc.test.mligo"
