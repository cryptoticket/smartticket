pragma solidity ^0.4.23;

contract AccessControl {
    address public addressCT;
    address public addressTS;
    address public addressOG;
    
    mapping (address => bool) public sellers;

    bool isPaused = false;
    bool isCancelled = false;

    modifier onlyCT() {require(msg.sender == addressCT); _;}
    modifier onlyTS() {require(msg.sender == addressTS); _;}
    modifier onlyAdmin() {require(msg.sender == addressCT || msg.sender == addressTS || msg.sender == addressOG); _;}
    modifier onlySeller() {require(sellers[msg.sender] == true); _;}

    modifier isEventActive() {require(!isPaused && !isCancelled); _;}

    constructor (address _addressCT, address _addressTS, address _addressOG) public {
        addressCT = _addressCT;
        addressTS = _addressTS;
        addressOG = _addressOG;

        sellers[_addressCT] = true;
        sellers[_addressTS] = true;
        sellers[_addressOG] = true;
    }

    function setTS(address _addressTS) onlyCT() external {
        require(_addressTS != address(0));  
        addressTS = _addressTS;
    }

    function setOG(address _addressOG) onlyCT() external {
        require(_addressOG != address(0));  
        addressOG = _addressOG;
    }

    function setSeller(address _seller) onlyAdmin() external {
        require(_seller != address(0));  
        sellers[_seller] = true;
    }

    function unsetSeller(address _seller) onlyAdmin() external {
        require(_seller != address(0));  
        sellers[_seller] = false;
    }

    function pause() onlyAdmin() isEventActive() external {
        isPaused = true;
    }

    function unpause() onlyAdmin() external {
        require(isPaused && !isCancelled);
        isPaused = false;
    }

    function cancel() onlyCT() external {
        isCancelled = true;
    }
}