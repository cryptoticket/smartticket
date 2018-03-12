const Event = artifacts.require("./Event.sol");

const NULL_ADDRESS = "0x0000000000000000000000000000000000000000";

contract("Event", function(accounts) {
    const deployer = accounts[0];

    const addressCT = accounts[1];
    const addressTS = accounts[2];
    const addressOG = accounts[3];

    const initialParams = {
        _version: "1.0.0-test", 
        _ipfs: "Qmc4QEgAFeM7jiqZA8AfSZjG2bXuj7ScP1pqgNU6Ff8A9y",
        _addresses: [addressCT, addressTS, addressOG],
        _saleStart: (Date.now() - 24 * 60 * 60 * 1000) / 1000 | 0, //yesterday
        _saleEnd: (Date.now() + 7 * 24 * 60 * 60 * 1000) / 1000 | 0, // next week
        _limit: 2,
        _limitPerHolder: 1,
        _isRefundable: true,
        _isTransferable: true,
    };

    beforeEach(async function() {
        event = await Event.new(...Object.values(initialParams));
    });

    it("should set initial attributes", async function() {
        assert.equal(await event.version(), initialParams._version);
        assert.equal(await event.metadata(), initialParams._ipfs);

        assert.equal(await event.saleStart(), initialParams._saleStart);
        assert.equal(await event.saleEnd(), initialParams._saleEnd);

        assert.equal(await event.addressCT(), addressCT);
        assert.equal(await event.addressTS(), addressTS);
        assert.equal(await event.addressOG(), addressOG);
    });

    const addressCustomer1 = accounts[4];
    const addressCustomer2 = accounts[5];
    const addressCustomer3 = accounts[6];

    const ticket1 = "0xaba3e430ab0129f70abadeb3e22cd116df9d8008375cffcc47641f3cdc46fb9e";
    const ticket2 = "0xd8ccc80aa8e0131c2a94f9c7898ad593e4340bff2690a2b7043a7fc45afac1e5";
    const ticket3 = "0xebcceb8378d5e5abdebc6c1f4898fc02d42bbf25cdbe57d40d889b44d71aa985";
    const ticket4 = "0x84e3703e4a38b86f9b7c6fd1fd8e886adcd75550ba76c0acd437fa7baad69b3a";
    const ticket5 = "0xe30381f5d5f5f1ebd442e2b9c6ac89932ebf039c653c399eb871a0874a3ca7fa";
    const ticket6 = "0x9022189a1208dea8381fe6278c92cbdfd4a4f36476d6670d840eafda3471e0ff";

    it("should sucessfully allocate ticket", function(done){    
        var events = event.TicketAllocated();

        event.allocate(addressCustomer1, ticket1, {
            from: addressCT
        }).then(new Promise(function(resolve, reject){
            events.watch(function(error, log){ resolve(log, done); });
        }).then(function(log, done){
            assert.equal(log.event, "TicketAllocated");
            assert.equal(log.args._to, addressCustomer1);
            assert.equal(log.args._ticket, ticket1);
            assert.equal(log.args._manager, addressCT);
        }).then(done).catch(done));
    });

    it("should sucessfully transfer ticket", function(done){    
        var events = event.TicketTransferred();

        event.allocate(addressCustomer1, ticket1, {
            from: addressCT
        }).then(function(status){
            event.transferFrom(addressCustomer1, addressCustomer2, ticket1, {from: addressCT});
        }).then(new Promise(function(resolve, reject){
            events.watch(function(error, log){ resolve(log, done); });
        }).then(function(log, done){
            assert.equal(log.event, "TicketTransferred");
            assert.equal(log.args._to, addressCustomer2);
            assert.equal(log.args._from, addressCustomer1);
            assert.equal(log.args._ticket, ticket1);
            assert.equal(log.args._manager, addressCT);
        }).then(done).catch(done));
    });

    it("should sucessfully redeem ticket", function(done){    
        var events = event.TicketRedeemed();

        event.allocate(addressCustomer1, ticket1, {from: addressCT}).then(function(){
            event.redeem(addressCustomer1, ticket1, {from: addressCT});
        }).then(new Promise(function(resolve, reject){
            events.watch(function(error, log){ resolve(log, done); });
        }).then(function(log, done){
            assert.equal(log.event, "TicketRedeemed");
            assert.equal(log.args._from, addressCustomer1);
            assert.equal(log.args._ticket, ticket1);
            assert.equal(log.args._manager, addressCT);
        }).then(done).catch(done));
    });

    it("should sucessfully refund ticket", function(done){    
        var events = event.TicketRefunded();

        event.allocate(addressCustomer1, ticket1, {from: addressCT}).then(function(){
            event.refund(addressCustomer1, ticket1, {from: addressCT});
        }).then(new Promise(function(resolve, reject){
            events.watch(function(error, log){ resolve(log, done); });
        }).then(function(log, done){
            assert.equal(log.event, "TicketRefunded");
            assert.equal(log.args._to, addressCustomer1);
            assert.equal(log.args._ticket, ticket1);
            assert.equal(log.args._manager, addressCT);
        }).then(done).catch(done));
    });

    it("should revert allocation over total limit", async function() {
        try {
            await event.allocate(addressCustomer1, ticket1, {from: addressCT});
            await event.allocate(addressCustomer2, ticket2, {from: addressCT});
            await event.allocate(addressCustomer3, ticket3, {from: addressCT});
        } catch (error) {
            assert.notEqual(error, undefined);
            assert.isAbove(error.message.search('revert'), -1);
        }
    });

    it("should revert allocation over limit per holder", async function() {
        try {
            await event.allocate(addressCustomer1, ticket1, {from: addressCT});
            await event.allocate(addressCustomer1, ticket2, {from: addressCT});
        } catch (error) {
            assert.notEqual(error, undefined);
            assert.isAbove(error.message.search('revert'), -1);
        }
    });

    it("should revert ticket refund for other customer", async function() {
        try {
            await event.allocate(addressCustomer1, ticket1, {from: addressCT});
            await event.refund(addressCustomer2, ticket1, {from: addressCT});
        } catch (error) {
            assert.notEqual(error, undefined);
            assert.isAbove(error.message.search('revert'), -1);
        }
    });


});