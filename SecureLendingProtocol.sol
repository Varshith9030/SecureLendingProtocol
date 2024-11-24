// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureLendingProtocol {
    mapping(address => uint) public deposits;
    mapping(address => uint) public debts;
    uint public totalDeposits;

    bool private locked;

    modifier noReentrancy() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function borrow(uint amount) public noReentrancy {
        require(deposits[msg.sender] >= amount, "Insufficient collateral");
        require(amount <= address(this).balance, "Insufficient contract funds");

        debts[msg.sender] += amount;
        deposits[msg.sender] -= amount;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");
    }

    function repay() public payable noReentrancy {
        require(msg.value > 0, "Repayment must be greater than 0");
        require(debts[msg.sender] >= msg.value, "Repaying more than owed");

        debts[msg.sender] -= msg.value;
        deposits[msg.sender] += msg.value;
    }

    function getCollateralBalance(address user) public view returns (uint) {
        return deposits[user] - debts[user];
    }
}
