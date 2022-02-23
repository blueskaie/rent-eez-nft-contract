const RentEezNFT = artifacts.require("./RentEezNFT");
module.exports = function (deployer) {
  deployer.then(async () => {
    await deployer.deploy(RentEezNFT);
  })
};