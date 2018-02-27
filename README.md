# [Draft] Events Smart Contract Standard v.0.0.1-alpha

## Specifications

### Public Variables

#### string public version
Smart Contract Standard version.

#### string public metadata
IPFS merkle root hash.

#### mapping (address => uint) public owners
Array with tokens owners balance.

#### mapping (bytes32 => address) public allocatedTickets
Array with list of allocated tickets tokens.

#### mapping (bytes32 => address) public redeemedTickets
Array with list of redeemed tickets tokens.


### Methods

#### function allocate(address _to, bytes32 _ticket) external returns(bool status)
Allocate `_ticket` token `_to` address and MUST fire the `TicketAllocated` event. The function SHOULD throw if the `_ticket` was already allocated or redeemed.

#### function transfer(address _to, bytes32 _ticket) external returns(bool status)
Transfer `_ticket` token `_from` method caller address `_to` another address and MUST fire the `TicketTransferred` event. The function SHOULD throw if the `_from` account does not own `_ticket` token.

#### function transferFrom(address _from, address _to, bytes32 _ticket) external returns(bool status)
Transfer `_ticket` token `_from` address `_to` another address and MUST fire the `TicketTransferred` event. The function SHOULD throw if the `_from` account does not own `_ticket` token.

#### function redeem(address _from, bytes32 _ticket) external returns(bool status)
Redeem `_ticket` token `_from` address and MUST fire the `TicketRedeemed` event. Function SHOULD throw if `_from` address not own `_ticket` token, or token already used.

#### function refund(address _to, bytes32 _ticket) external returns(bool status)
Refund `_ticket` token `_to` address and MUST fire `TicketRefunded` event.


### Events

#### TicketAllocated(address _to, bytes32 _ticket, address _manager)
Triggered when `_ticket` token are allocated.

#### TicketRedeemed(address _from, bytes32 _ticket, address _manager)
Triggered when `_ticket` token are redeemed.

#### TicketTransferred(address _from, address _to, bytes32 _ticket, address _manager)
Triggered when `_ticket` tokens are transferred.

#### TicketRefunded(address _to, bytes32 _ticket, address _manager)
Triggered when `_ticket` token are refunded.


### IPFS Metadata Structure

#### Event Metadata

Example: https://ipfs.io/ipfs/Qmc4QEgAFeM7jiqZA8AfSZjG2bXuj7ScP1pqgNU6Ff8A9y/

#### Ticket Metadata

Example: https://ipfs.io/ipfs/Qmcvwt7DJdgephhpcr8iqwMkcy4Nj5Uz1sGPb5x2vHt4jW/

## Implementation
Expansion of this standard for event tickets market can be found at
[crypto.tickets](https://github.com/cryptoticket/#) GitHub

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
