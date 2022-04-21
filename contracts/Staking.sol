pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {

    IERC20 TKN;

constructor(IERC20 _token) {
    TKN = _token;
}




}