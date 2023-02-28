// SPDX-License-Identifier: GPL-3.0
// Unit testing for the LizardLounge Contract

pragma solidity 0.8.17;

interface IUSDc {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address _owner) external returns (uint256);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);
}
