pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20 {

    constructor() ERC20("TKN", "tkn") {
        _mint(msg.sender, 100000000000 * 10 ** 18);
    }

    function mint(address account, uint256 amount) public {
        super._mint(account, amount);
    }}