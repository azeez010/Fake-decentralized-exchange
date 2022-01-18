const FakeToken = artifacts.require("FakeToken.sol");
const Dex = artifacts.require("Dex.sol");

module.exports = async function  (deployer) {
  let tokenSupply = 100000;
  deployer.deploy(FakeToken, "FKT", "Fake World", tokenSupply);
  
  // tokenSupply = 3000000;
  // await deployer.deploy(FakeToken, "AI", "Air plug", tokenSupply);
  let a = await FakeToken.deployed()
  // console.log(a) 
  tokenSupply = 6000000;
  await deployer.deploy(Dex, "Dex", "Exchange", tokenSupply);
  let dex = await Dex.deployed()
  let addr = await dex.exchangeToken()
  console.log(addr)

};
