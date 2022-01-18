// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IFakeToken {
    function transfer(address _to, uint256 _value) external  returns(bool, uint256);
    function mint(uint256 tokens) external  returns(bool, uint256);
    function buyToken() payable external  returns(bool, uint256);
    function showDetails()  external  view returns(string memory, string memory, uint256, uint8);
    function tokenLeftUnMint() external view returns(uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool, uint256);
    function balanceOf(address _of) external view returns(uint256);
}