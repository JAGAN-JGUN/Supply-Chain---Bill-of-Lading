const Migrations = artifacts.require("Test1");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
