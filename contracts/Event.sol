pragma solidity ^0.4.24;

import "./tickets/TicketsManagement.sol";

contract Event is TicketsManagement {
    string public version;
    string public metadata;

    function Event(
        string _version,
        string _ipfs,
        address[] _addresses,
        uint _saleStart,
        uint _saleEnd,
        uint _limit,
        uint _limitPerHolder,
        bool _isRefundable, 
        bool _isTransferable
    ) AccessControl(
        _addresses
    ) EventSettings(
        _saleStart,
        _saleEnd,
        _limit,
        _limitPerHolder,
        _isRefundable,
        _isTransferable
    )
        public
    {
        version = _version;
        metadata = _ipfs;
    }

    function setMetadataHash(string _ipfs) external returns(bool) {
        metadata = _ipfs;
        return true;
    }
}