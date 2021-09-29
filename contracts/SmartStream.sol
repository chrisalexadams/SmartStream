//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract SmartStream {
    using SafeERC20 for IERC20;

    address internal paymentToken;
    uint internal _totalShares;
    uint internal _totalTokenReleased;
    address[] internal _payees;
    mapping(address => uint) internal _shares;
    mapping(address => uint) internal _tokenReleased;

    event PayeeAdded(address account, uint shares);
    event PaymentReleased(address to, uint amount);
    
    constructor(
        address[] memory payees, 
        uint[] memory shares_,
        address _paymentToken
    ) {
        require(
            payees.length == shares_.length,
            "SmartStream: payees and shares length mismatch"
        );

        require(payees.length > 0, "SmartStream: no payees");
        for (uint i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
        paymentToken = _paymentToken;

    }


    function totalShares() public view returns (uint) {
        return _totalShares;
    }

    function shares(address account) public view returns (uint) {
        return _shares[account];
    }

    function payee(uint index) public view returns (address) {
        return _payees[index];
    }

    function _addPayee(address account, uint shares_) internal {
        require(account != address(0), "SmartStream: account is the zero address");
        require(shares_ > 0, "SmartStream: shares are 0");
        require(_shares[account] == 0, "SmartStream: account already has shares");
        _payees.push(account); // called in the constructor
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }


    function release(address account) public virtual {
        require(_shares[account] > 0, "SmartStream: account has no shares");
        
        uint tokenTotalReceived = IERC20(paymentToken).balanceOf(address(this)) + _totalTokenReleased;
    
        uint payment = (tokenTotalReceived * _shares[account]) / _totalShares - _tokenReleased[account];
    
        require(payment != 0, "SmartStream: account is not due payment");
        _tokenReleased[account] = _tokenReleased[account] + payment;
        _totalTokenReleased = _totalTokenReleased + payment;
        IERC20(paymentToken).safeTransfer(account, payment);
        emit PaymentReleased(account, payment);
    }
}
