// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LockedFunds {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Anyone can deposit ETH
    function deposit() external payable {}

    // Owner can withdraw ETH, but there is an unnecessary check
    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(address(this).balance == amount, "Balance not exactly equal");

        (bool sent,) = owner.call{value: amount}("");
        require(sent, "Transfer failed");
    }
}
