// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// Solidity developer tech assignment
// Your task is to create a staking contract.
// Users stake different quantities of ERC-20 token named “TKN”. Assume that an external caller would periodically transfer reward TKNs to a staking smart contract (no need to implement this logic). Rewards are proportionally distributed based on staked TKN.
// Contract caller can:
// - Stake
// - Unstake (would be a plus if caller can unstake part of stake)
// - See how many tokens each user can unstake
// Main info:
// - Use Solidity as a main language (version higher than 0.4.0)
// - Cover contract with unit tests. You can use Truffle or Hardhat
// When finished, push code to your github and provide a link for us.
// If you have any questions - feel free to write to us. Good luck!

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {

    IERC20 TKN;
    
    uint rewardRate = 100;
    uint lastReward;
    uint rewardPerToken;
    uint holdings;

    mapping (address => uint) bals;
    mapping (address => uint) rewards;
    mapping (address => uint) rewardPerTokenHeld;
    
    constructor(IERC20 _TKN) {
        TKN = _TKN;
    }



    function stake(uint _amount) external {
        require(_amount != 0, "stake more");
        holdings += _amount;
        bals[msg.sender] += _amount;
        TKN.transferFrom(msg.sender, address(this), _amount);
    }
    
    function unstake(uint _amount) external {
        require(_amount != 0, "unstake more");
        require(bals[msg.sender] >= _amount, "balance too low");
        holdings -= _amount;
        bals[msg.sender] -= _amount;
        TKN.transfer(msg.sender, _amount);
    }

}