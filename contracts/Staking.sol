// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// Solidity developer tech assignment
// Your task is to create a staking contract.
// Users stake different quantities of ERC-20 token named “TKN”. Assume that an public caller would periodically transfer reward TKNs to a staking smart contract (no need to implement this logic). Rewards are proportionally distributed based on staked TKN.
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
    
    uint public rewardRate = 100;
    uint public lastReward;
    uint public rewardPerToken;
    uint public holdings;

    mapping (address => uint) public bals;
    mapping (address => uint) public rewards;
    mapping (address => uint) public rewardPerTokenStaked;

    event Stake(address _who, uint _amount);
    event Unstake(address _who, uint _amount);
    event Harvest(address _who, uint _amount);
    
    constructor(IERC20 _TKN) {
        TKN = _TKN;
    }

    function stake(uint _amount) external syncRewards(msg.sender) {
        require(_amount != 0, "stake more");
        holdings += _amount;
        bals[msg.sender] += _amount;
        TKN.transferFrom(msg.sender, address(this), _amount);
        emit Stake(msg.sender, _amount);
    }
    
    function unstake(uint _amount) external syncRewards(msg.sender) {
        require(_amount != 0, "unstake more");
        require(bals[msg.sender] >= _amount, "balance too low");
        holdings -= _amount;
        bals[msg.sender] -= _amount;
        harvest();
        TKN.transfer(msg.sender, _amount);
        emit Unstake(msg.sender, _amount);
    }
    
    function harvest() public syncRewards(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        TKN.transfer(msg.sender, reward);
        emit Harvest(msg.sender, reward);
    }

    function getRewardPerToken() public view returns(uint){
        if(holdings == 0){
            return rewardPerToken;
        }
        return rewardPerToken + (((block.timestamp - lastReward) * rewardRate * 1e18) / holdings);
    }

    function getRewardsEarned(address _who) public view returns(uint){
        return ((bals[_who] * (getRewardPerToken() - rewardPerTokenStaked[_who])) / 1e18) + rewards[_who];
    }

    modifier syncRewards(address _who) {
        rewardPerToken = getRewardPerToken();
        lastReward = block.timestamp;

        rewards[_who] = getRewardsEarned(_who);
        rewardPerTokenStaked[_who] = rewardPerToken;
        _;
    }
}