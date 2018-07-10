pragma solidity ^0.4.23;

import "./TicketsManagement.sol";

contract Event is TicketsManagement {
    string public version;
    string public metadata;

    event MetadataUpdated(string _metadata);
    
    constructor (
        string _version,
        string _ipfs,
        address _addressCT,
        address _addressTS, 
        address _addressORG,
        uint _saleStart,
        uint _saleEnd, 
        uint _limit,
        uint _limitPerHolder, 
        bool _isRefundable,
        bool _isTransferable
    ) AccessControl(
        _addressCT, 
        _addressTS,
        _addressORG
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

    function updateMetadata(string _ipfs) external onlyAdmin() returns(bool) {
        metadata = _ipfs;

        emit MetadataUpdated(_ipfs);
        return true;
    }
}