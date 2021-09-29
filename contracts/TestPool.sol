//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./SmartStream.sol";

contract MockPool is Ownable, SmartStream {
    using SafeERC20 for IERC20;
    constructor(
        address[] memory _payees,
        uint[] memory _shares,
        address _paymentToken
    ) SmartStream(_payees, _shares, _paymentToken) {}

    // safety check
    function drainTo(address _transferTo, address _token) public onlyOwner {
        require(
        _token != paymentToken,
        "TestPool: Token to drain is PaymentToken"
        );
        uint balance = IERC20(_token).balanceOf(address(this));
        require(balance > 0, "TestPool: Token to drain balance is 0");
        IERC20(_token).safeTransfer(_transferTo, balance);
    }
}