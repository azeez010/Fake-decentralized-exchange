// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IFakeToken.sol";

contract FakeToken is IFakeToken{
  string private name;
  string private symbol; 
  uint256 private totalSupply;
  uint256 private totalTokensLeft;
  address private owner;
  uint8 private decimals = 18;


  mapping(address => uint256) private balance;

  constructor(string memory _symbol, string memory _name, uint256 _totalSupply) {
      owner = tx.origin;
      name = _name;
      symbol = _symbol;
      totalSupply = _totalSupply * (10 ** decimals);
      totalTokensLeft = _totalSupply * (10 ** decimals);
  }

  function showDetails() public override view returns(string memory, string memory, uint256, uint8)  {
    return (symbol, name, totalSupply, decimals);

  }

  function tokenLeftUnMint() public override view returns(uint256)  {
    return totalTokensLeft;

  }

  function balanceOf(address _of) public view returns(uint256) {
    return balance[_of];
  }
  
  modifier onlyOwner {
    require(owner == tx.origin);
    _;
  }

  function mint(uint256 tokens) public override onlyOwner returns(bool, uint256) {
    _mint(tokens);
    return (true, tokens);
  }
  
  function _mint(uint256 tokens) internal {
    require(totalTokensLeft > 0);
    totalTokensLeft -= tokens;
    balance[msg.sender] += tokens; 
  }

  function buyToken() payable public  override returns(bool, uint256) {
    uint256 tokensRate = 100;
    tokensRate *= msg.value;
    require(totalTokensLeft >= tokensRate);
    balance[msg.sender] += tokensRate;
    totalTokensLeft -= tokensRate;
    return (true, tokensRate);
  }

  function transfer(address _to, uint256 _value) public override returns(bool, uint256) {
    require(balance[msg.sender] >= _value);
    balance[msg.sender] -= _value;
    balance[_to] += _value;
    return (true, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public override returns(bool, uint256) {
    require(balance[_from] >= _value);
    balance[_from] -= _value;
    balance[_to] += _value;
    return (true, _value);
  }
}
