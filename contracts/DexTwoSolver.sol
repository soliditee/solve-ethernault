// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./token/ERC20/IERC20.sol";
import "./token/ERC20/ERC20.sol";
import "./math/SafeMath.sol";
import "./access/Ownable.sol";

contract DexTwo is Ownable {
    using SafeMath for uint256;
    address public token1;
    address public token2;

    constructor() public {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function add_liquidity(address token_address, uint256 amount) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(
        address from,
        address to,
        uint256 amount
    ) public {
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint256 swapAmount = getSwapAmount(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapAmount(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
        SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableTokenTwo is ERC20 {
    address private _dex;

    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) public returns (bool) {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }

    // Create a new function to bypass the error "... approve is not a function" when running on local hardhat
    function approveNew(
        address owner,
        address spender,
        uint256 amount
    ) public returns (bool) {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}
