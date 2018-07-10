pragma solidity ^0.4.23;

contract AccessControl {
    address public addressCT;
    address public addressTS;
    address public addressOG;
    
    mapping (address => bool) public sellers;

    bool isPaused = false;
    bool isCancelled = false;

    modifier onlyCT() {require(msg.sender == addressCT, "Access restricted"); _;}
    modifier onlyTS() {require(msg.sender == addressTS, "Access restricted"); _;}
    modifier onlyAdmin() {
        require(
            msg.sender == addressCT || 
            msg.sender == addressTS || 
            msg.sender == addressOG, "Access restricted"
        );
        _;
    }
    modifier onlySeller() {require(sellers[msg.sender] == true, "Access restricted"); _;}
    modifier isEventActive() {
        require(!isPaused, "Event is paused");
        require(!isCancelled, "Event is canceled");
        _;
    }

    constructor (address _addressCT, address _addressTS, address _addressOG) public {
        addressCT = _addressCT;
        addressTS = _addressTS;
        addressOG = _addressOG;

        sellers[_addressCT] = true;
        sellers[_addressTS] = true;
        sellers[_addressOG] = true;
    }

    function setTS(address _addressTS) onlyCT() external {
        require(_addressTS != address(0), "Invalid address");
        addressTS = _addressTS;
    }

    function setOG(address _addressOG) onlyCT() external {
        require(_addressOG != address(0), "Invalid address");
        addressOG = _addressOG;
    }

    function setSeller(address _seller) onlyAdmin() external {
        require(_seller != address(0), "Invalid address");
        sellers[_seller] = true;
    }

    function unsetSeller(address _seller) onlyAdmin() external {
        require(_seller != address(0), "Invalid address");
        sellers[_seller] = false;
    }

    function pause() onlyAdmin() isEventActive() external {
        isPaused = true;
    }

    function unpause() onlyAdmin() external {
        require(isPaused, "Event is active");
        require(!isCancelled, "Event is cancelled");
        isPaused = false;
    }

    function cancel() onlyCT() external {
        isCancelled = true;
    }
}