// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IFakeToken.sol";
import "./FakeToken.sol";

contract Dex {
    struct Token {
        string name;
        string symbol;
        address addr;
    }

    Token private token;
    Token private nativeToken;

    
    FakeToken internal DexToken;
    Token[] public tokenManaged;

    mapping(address=>uint256) lastStakeTime;
    mapping(address=> mapping(address=>uint256)) allowance;
    mapping(address=>uint256) liquidityPool;

    address private owner;
    
    //  10 tokens 15 secs and per 100 tokens staked 
    uint256 private nativeTokenRate = 10;   

    event NewTokenAdded(address indexed addr, string symbol, string name  );

    constructor(string memory _symbol, string memory _name, uint256 _totalSupply) {
        owner = msg.sender;
        DexToken = new FakeToken(_symbol, _name, _totalSupply);
        (,,,decimals) = DexToken.showDetails() 
        // The contract should mint all the tokens for itself.
        uint256 allTokens = _totalSupply * (10 ** decimals);
        DexToken.mint(allTokens);
        nativeToken(_name, _symbol, address(DexToken));
    }

    function exchangeToken() public view returns(address) {
        return address(DexToken);
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
  }
  
    function tokenAvailable(string memory _symbol) internal view returns(uint256) {
        bool isPresent = false;
        uint256 index; 

        for(uint256 i = 0; i < tokenManaged.length; i++){
            if(keccak256(abi.encodePacked(tokenManaged[i].symbol)) == keccak256(abi.encodePacked(_symbol)) ){
                isPresent = true;
                index = i;
            }
        }
        require(isPresent, "No such token");
        return index;
    }

    
    function addToken(address addr, string memory symbol, string memory name) public onlyOwner {
        token = Token(name, symbol, addr);
        tokenManaged.push(token);
    }

    function getAllTokens() public view returns(Token[] memory){
        return tokenManaged;
    }

    function stakeToken(string memory _symbol, uint256 _value) public {
        uint256 tokenIndex = tokenAvailable(_symbol);
        IFakeToken fakeToken = IFakeToken(tokenManaged[tokenIndex].addr);
        // Check if there is enough allowed token
        // require(allowance[msg.sender][tokenManaged[tokenIndex].addr] > _value, "Insufficient allowed staking token");
        require(fakeToken.balanceOf(msg.sender) > _value, "Insufficient balance");

        fakeToken.transferFrom(msg.sender, address(this), _value);
        // Increase the allowance, The amount of token left
        allowance[msg.sender][tokenManaged[tokenIndex].addr] += _value;
        // Register the token The contract now possess
        liquidityPool[tokenManaged[tokenIndex].addr] += _value;
        lastStakeTime[msg.sender] = block.timestamp;
    }

    // function allowStaking(string memory _symbol, uint256 _value) public {
    //     uint256 tokenIndex = tokenAvailable(_symbol);
    //     IFakeToken fakeToken = IFakeToken(tokenManaged[tokenIndex].addr);
    //     require(fakeToken.balanceOf(msg.sender) > _value, "Insufficient balance");
        
    //     // Making sure to keep track of tokens Staked
    //     allowance[msg.sender][tokenManaged[tokenIndex].addr] = _value;       
    // }

    function collectReward(string memory _symbol, uint256 _value) public {
        uint256 tokenIndex = tokenAvailable(_symbol);
        IFakeToken fakeToken = IFakeToken(tokenManaged[tokenIndex].addr);
        uint256 rewardValue = rewardAlgorithm(_value); 
        DexToken.transferFrom(address(this), msg.sender, rewardValue);
        fakeToken.transferFrom(address(this), msg.sender, _value);
        
        // Increase the allowance, The amount of token left
        allowance[msg.sender][tokenManaged[tokenIndex].addr] -= _value;
        // Register the token The contract now possess
        liquidityPool[tokenManaged[tokenIndex].addr] -= _value;
    }

    function rewardAlgorithm(uint256 _value) private view returns(uint256) {
        uint256 timeDelta = block.timestamp - lastStakeTime[msg.sender];
        timeDelta /= 15 seconds;
        return  ( _value / nativeTokenRate ) * timeDelta;
    }
}