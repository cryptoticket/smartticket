pragma solidity ^0.4.24;

contract EventSettings {
    uint public saleStart;
    uint public saleEnd;

    uint public allocated;
    uint public limitTotal;
    uint public limitPerHolder;

    bool isRefundable;
    bool isTransferable;

    modifier refundable() {require(isRefundable); _;}
    modifier transferable() {require(isTransferable); _;}

    modifier isSaleActive() {
        require(block.timestamp > saleStart && block.timestamp < saleEnd); _;
    }

    constructor(
        uint _saleStart, 
        uint _saleEnd,  
        uint _limitTotal, 
        uint _limitPerHolder, 
        bool _isRefundable, 
        bool _isTransferable
    ) 
        public     
    {
        saleStart = _saleStart;
        saleEnd = _saleEnd;

        limitTotal = _limitTotal;
        limitPerHolder = _limitPerHolder;
        
        isRefundable = _isRefundable;
        isTransferable = _isTransferable;
    }
}