const { assert } = require('chai');

require('chai')
.use(require('chai-as-promised'))
.should();

const FakeToken = artifacts.require("FakeToken.sol");

contract("FakeToken", (accounts) => {
    describe("Test basic  functionalities...", async () =>{
        it("Should be testable", async() => {
            let tokenSupply = 100000;
            let decimals = 18; 
            
            const fake = await FakeToken.new("FKT", "Fake World", tokenSupply, decimals )
            // const Sym = await fake.symbol()
            console.log(fake.address, tokenSupply)
            const {0: symbol, 1: name, 2: tokenTotalSupply, 3: tokenDecimals} = await fake.showDetails()
            
            console.log(symbol, name, tokenTotalSupply, tokenDecimals)
            let tokenLeft = await fake.tokenLeftUnMint()
            console.log(tokenLeft.toString(), " tokenLeft")
            await fake.mint(150000)
    
            tokenLeft = await fake.tokenLeftUnMint()
            console.log(tokenLeft.toString(), " tokenLeft")
            
            await fake.buyToken({from: accounts[1],  value: web3.utils.toWei("0.01", "ether")})
            // console.log(tx)
            let balance = await fake.balanceOf(accounts[1])
            console.log(balance.toString(), web3.utils.toWei("0.1", "ether"))
            // tokenBought.toString()
            let tokenLeftAfter = await fake.tokenLeftUnMint()
            
            assert(tokenLeft != tokenLeftAfter)
        })
    })
})