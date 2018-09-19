pragma solidity ^0.4.24;

import "../libs/SafeMath.sol";

contract WithdrawEtherControl {
    using SafeMath for uint256;

    uint internal feeCT;
    uint internal feeTS;
    uint internal feeOG;

    mapping (address => uint256) public balanceInEther;

    event Withdraw(address user, uint256 amount, uint256 balance);

    constructor(uint[] _fees) internal {
        require(_fees[0] + _fees[1] + _fees[2] == 100);

        feeCT = _fees[0];
        feeTS = _fees[1];
        feeOG = _fees[2];
    }

    function withdraw(uint256 amount) public {
        require(amount > 0 && balanceInEther[msg.sender] > 0 && balanceInEther[msg.sender] <= amount);

        balanceInEther[msg.sender] = balanceInEther[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit Withdraw(msg.sender, amount, balanceInEther[msg.sender]);
    }
}