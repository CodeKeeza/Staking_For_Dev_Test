const Token = artifacts.require("Token");
const Staking = artifacts.require("Staking");

module.exports = async function (deployer) {
    const token = await deployer.deploy(Token);
    const iToken = await Token.deployed();
    const staking = await deployer.deploy(Staking, iToken.address);
};
