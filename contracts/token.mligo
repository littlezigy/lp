#include "FA1.2.mligo"

type parameter = Transfer of transfer | Approve of approve | GetAllowance of getAllowance | GetBalance of getBalance | GetTotalSupply of getTotalSupply
let main ((p,s):(parameter * storage)) = match p with
   Transfer       p -> transfer       p s
|  Approve        p -> approve        p s
|  GetAllowance   p -> getAllowance   p s
|  GetBalance     p -> getBalance     p s
|  GetTotalSupply p -> getTotalSupply p s
