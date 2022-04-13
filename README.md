# Split Deposits to the users
This contract allows to split Ether & ERC20 payments among a list of accounts. 
The amounts can be in equal parts or in any other arbitrary proportion. The way this 
should be handled is by assigning each account a number of shares. The payments should 
not be forwarded to the accounts automatically but kept in the contract. The actual 
transfer should be triggered by a separate call by each recipient account.
The sender specify time for releasing of the funds to simulate “money streaming”

## Example 1
### List of addresses:
- 0x047425f8d784dcc6d73df12bc6eeca3aa51f4fb2 <br/>
- 0x522eb82b8394f1abc499be2b986b79feaf7e451e
### Shares
- 30% <br/>
- 70%
### Result
1 ETH is being split: <br/>
- 0x047425f8d784dcc6d73df12bc6eeca3aa51f4fb2 should be able to withdraw 0.3 ETH  <br/>
- 0x522eb82b8394f1abc499be2b986b79feaf7e451e should be able to withdraw 0.7 ETH

## Example 2
### List of addresses:
- 0x047425f8d784dcc6d73df12bc6eeca3aa51f4fb2 <br/>
- 0x522eb82b8394f1abc499be2b986b79feaf7e451e
### Shares
- 30% <br/>
- 70%
### Streaming time
- 2592000 (~1 month)
### Result
- 0x047425f8d784dcc6d73df12bc6eeca3aa51f4fb2 should be able to withdraw  <br/>
0.000000115740741 ETH every second that passes up to 0.3 ETH after 1 month <br/>
- 0x522eb82b8394f1abc499be2b986b79feaf7e451e should be able to withdraw  <br/>
0.000000270061728 ETH every second up to 0.7 ETH after 1 month
