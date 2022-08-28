# Lending Protocol
Lending protocol for Tezos Money Legos hackathon

## Lending Protocol contract
### Line of Credit (Credit Delegation)
- `loc_limit()`: This is the percent of pool to allow borrowers (ie delegates) borrow from. If `loc_buffer` is set to 50%, borrowers under this line of credit can collectively borrow up to 50% of creditors loan limit.
Once the loc_limit has been reached, any new borrow actions to this line of credit will fail until loans are paid back by the delegators and the loc utiliztion amount falls to under the `loc_limit`

- `loc_buffer()`: This is a buffer between the current loan utilization amount of the creditor, and the max loan utilization amount (at which the creditor's collateral will be automatically liquidated). The default is 30%. It protects the creditor from automatic loan liquidation by stopping borrows if the loc amount combined with the creditor's own borrowed assets are at or above the buffer.
