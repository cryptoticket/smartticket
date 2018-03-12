pragma solidity ^0.4.18;

import "./tickets/PayalableTicketsManagement.sol";

contract EventPayableWithEther is PayalableTicketsManagement {
    string public version;
    string public metadata;

    function EventPayableWithEther(
        string _version,
        string _ipfs,
        address[] _addresses,
        uint _saleStart,
        uint _saleEnd,
        uint _limit,
        uint _limitPerHolder,
        bool _isRefundable,
        bool _isTransferable,
        uint[] _fees
    ) AccessControl(
        _addresses
    ) EventSettings(
        _saleStart,
        _saleEnd,
        _limit,
        _limitPerHolder,
        _isRefundable,
        _isTransferable
    ) WithdrawEtherControl(
        _fees
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