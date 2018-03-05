var Event = artifacts.require("./Event.sol");

module.exports = function(deployer) {

const addressCT = "0x9071833bc54fc45ab9211ed0a77769776b9afec4";
const addressTS = "0x9071833bc54fc45ab9211ed0a77769776b9afec4";
const addressOG = "0x9071833bc54fc45ab9211ed0a77769776b9afec4";

  const arguments = {
    version: "1.0.0-test",
    metadata: "Qmc4QEgAFeM7jiqZA8AfSZjG2bXuj7ScP1pqgNU6Ff8A9y",

    limit: 5,
    limitperHolder: 2,

    saleStart: 1518100000,
    saleEnd: 1616117392,
    
    isRefundable: true,
    isTransferable: true        
};

  deployer.deploy(Event, 
    arguments.version, arguments.metadata, 
    addressCT, addressTS, addressOG,
    arguments.saleStart, arguments.saleEnd, 
    arguments.limit, arguments.limitPerHolder, 
    arguments.isRefundable, arguments.isTransferable
  );
};
