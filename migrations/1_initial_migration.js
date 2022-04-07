const NFTAuction = artifacts.require("NFTAuction");
module.exports = function (deployer) {
  deployer.then(async () => {
	  await deployer.deploy(NFTAuction);
  })
};