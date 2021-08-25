//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Stake is ERC20{
    
    constructor() ERC20('STAKE', '$STAKE'){
        _mint(msg.sender, 1000000 * 10**18);
    }
}