// the liquidity pool containing the assets
//SPDX-License-Identifier: MIT

import "./UnderlyingToken.sol";
import "./GovernanceToken.sol";
import "./LiquidityProviderToken.sol";

/* Flow
1. Provide Liquidity to the Protocol.
2. After providing liquidity, you get the same no of liquidity proider tokens in return.
3. After some time, you redeem your LP tokens and get your initial tokens back along with the rewards.
*/

/*The longer you provide liquidity, more is the reward (governance tokens) */

pragma solidity ^0.8.8;

contract LiquidityPool is LPToken {
    // checkpoints are used a reference to distribute governance token reward
    /* for example if an investor invests the underlying tokens on block no 10 and withdraws them on block number 15, then the reward will be 5 * tokens invested * reward_per_block  */
    mapping(address => uint) public checkPoints; // here uint is blocknumber
    UnderlyingToken public underlyingToken;
    GovernanceToken public governanceToken;
    uint public constant REWARD_PER_BLOCK = 1; // Investor will receive 1 governance token per block for each underlying token that they invest

    constructor(address _underlyingToken, address _governanceToken) {
        underlyingToken = UnderlyingToken(_underlyingToken);
        governanceToken = GovernanceToken(_governanceToken);
    }

    /* Initially deposit 10 tokens at block no 5
   Now Deposit at block 15 which means we will get a reward = 10 *10 *1 = 101 Governance Tokens
*/

    function deposit(uint256 _amount) external {
        if (checkPoints[msg.sender] == 0) {
            checkPoints[msg.sender] = block.number;
        }

        underlyingToken.transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
    }

    // Here amount is the no of LP token to withdraw (basically equal to the tokens invested in the pool)
    function withdraw(uint amount) external {
        require(balanceOf(msg.sender) >= amount, "Not enough LP tokens");
        _distributeRewards(msg.sender);
        underlyingToken.transfer(msg.sender, amount);
        _burn(msg.sender, amount);
    }

    function _distributeRewards(address beneficiary) internal {
        uint256 checkPoint = checkPoints[beneficiary];
        // if the investor deposits the token in the same block, this will be 0
        if (block.number - checkPoint > 0) {
            // we track how much the investor has invested using LP Token. Eg If i invest 10 USDT, I will get 10 LP tokens. So we just use balanceOf() of LPToken to know how much tokens we have invested instead of a mapping
            uint distributionAmount = balanceOf(beneficiary) *
                (block.number - checkPoint) *
                REWARD_PER_BLOCK;
            governanceToken.mint(beneficiary, distributionAmount);
            checkPoints[beneficiary] = block.number;
        }
    }
}
