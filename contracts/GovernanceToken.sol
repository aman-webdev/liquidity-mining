// the governance token for the pool / product
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Only The owner of this contract i.e. LiquidityPool contract will be able to mint governance tokens
contract GovernanceToken is ERC20, Ownable {
    constructor() ERC20("Governance Token", "GVT") Ownable() {}

    function mint(address to, uint amount) external onlyOwner {
        _mint(to, amount);
    }
}
