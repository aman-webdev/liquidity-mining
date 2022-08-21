// Token to be sent as a liquidity in the liquidity pool
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UnderlyingToken is ERC20 {
    constructor() ERC20("Underlying Token", "UGT") {}

    function faucet(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
