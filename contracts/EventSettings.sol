pragma solidity ^0.4.23;

contract EventSettings {
    uint public saleStart;
    uint public saleEnd;

    uint public allocated;
    uint public limitTotal;
    uint public limitPerHolder;

    bool isRefundable;
    bool isTransferable;

    modifier refundable() {require(isRefundable, "Event tickets is not refundable"); _;}
    modifier transferable() {require(isTransferable, "Event tickets is not transferable"); _;}

    modifier isSaleActive() {
        require(now > saleStart, "Event tickets sale not started yet");
        require(now < saleEnd, "Event tickets sale is finished"); 
        _;
    }

    constructor (
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