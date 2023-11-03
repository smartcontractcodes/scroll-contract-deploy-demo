// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Lock {
    uint public unlockTime;
    address payable public owner;
    bool private isWithdrawing;

    event Withdrawal(uint amount, uint when);

    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
        isWithdrawing = false;
    }

    modifier preventReentrancy() {
        require(!isWithdrawing, "Reentrancy attempt detected!");
        isWithdrawing = true;
        _;
        isWithdrawing = false;
    }

    function withdraw() public preventReentrancy {
        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        uint balance = address(this).balance;
        emit Withdrawal(balance, block.timestamp);

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
