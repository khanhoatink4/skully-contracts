const SKLToken = artifacts.require("./SKLToken.sol");
const SKLAuction = artifacts.require("./SKLAuction.sol");

module.exports = function(deployer) {
    // deployer.deploy(SKLToken);
    deployer.deploy(SKLAuction);
};
