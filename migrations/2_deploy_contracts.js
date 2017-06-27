//var Protocolo = artifacts.require("Protocolo");
var ProtocoloManager= artifacts.require("ProtocoloManager")


module.exports = function(deployer) {
   //deployer.deploy(Protocolo);
   deployer.deploy(ProtocoloManager);
};
