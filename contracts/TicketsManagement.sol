pragma solidity ^0.4.23;

import "./AccessControl.sol";
import "./EventSettings.sol";

contract TicketsManagement is AccessControl, EventSettings {
    mapping (address => uint) public owners;
    mapping (bytes32 => address) public allocatedTickets;
    mapping (bytes32 => address) public redeemedTickets;

    event TicketAllocated(address _to, bytes32 _ticket, address _manager);
    event TicketRefunded(address _to, bytes32 _ticket, address _manager);
    event TicketRedeemed(address _from, bytes32 _ticket, address _manager);
    event TicketTransferred(address _from, address _to, bytes32 _ticket, address _manager);

    function allocate(address _to, bytes32 _ticket) 
        onlyAdmin() 
        isEventActive() 
        isSaleActive() 
        external 
        returns(bool status) 
    {
        require(_to != address(0), "Invalid address");
        require(allocatedTickets[_ticket] == address(0), "Ticket allocated");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        if (limitTotal > 0) {require(allocated < limitTotal, "Ticket limit exceeded");}
        if (limitPerHolder > 0) {require(owners[_to] < limitPerHolder, "Customer ticket limit exceeded");}

        allocated++;
        allocatedTickets[_ticket] = _to;
        owners[_to] += 1;
            
        emit TicketAllocated(_to, _ticket, msg.sender);
        return true;
    }

    function transfer(address _to, bytes32 _ticket) 
        isEventActive() 
        isSaleActive() 
        external 
        returns(bool status) 
    {
        require(_to != address(0) && _to != msg.sender, "Invalid address");
        require(allocatedTickets[_ticket] == msg.sender, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        if (limitPerHolder > 0) {require(owners[_to] < limitPerHolder, "Customer ticket limit exceeded");}
        
        allocatedTickets[_ticket] = _to;
        owners[msg.sender] -= 1;
        owners[_to] += 1;

        emit TicketTransferred(msg.sender, _to, _ticket, msg.sender);
        return true;
    }

    function transferFrom(address _from, address _to, bytes32 _ticket) 
        onlyAdmin() 
        isEventActive() 
        isSaleActive() 
        external 
        returns(bool status) 
    {
        require(_to != address(0) && _from != address(0) && _to != _from, "Invalid address");
        require(allocatedTickets[_ticket] == _from, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        if (limitPerHolder > 0) {require(owners[_to] < limitPerHolder, "Customer ticket limit exceeded");}

        allocatedTickets[_ticket] = _to;
        owners[_from] -= 1;
        owners[_to] += 1;

        emit TicketTransferred(_from, _to, _ticket, msg.sender);
        return true;
    }

    function redeem(address _from, bytes32 _ticket) 
        onlyAdmin() 
        isEventActive() 
        external 
        returns(bool status) 
    {
        require(_from != address(0), "Invalid address");
        require(allocatedTickets[_ticket] == _from, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        redeemedTickets[_ticket] = _from;
        owners[_from] -= 1;

        emit TicketRedeemed(_from, _ticket, msg.sender);
        return true;
    }

    function refund(address _to, bytes32 _ticket) 
        onlyAdmin() 
        refundable() 
        external 
        returns(bool status) 
    {
        require(_to != address(0), "Invalid address");
        require(allocatedTickets[_ticket] == _to, "Ticket not belong to customer");
        require(redeemedTickets[_ticket] == address(0), "Ticket redeemed");

        allocated--;
        allocatedTickets[_ticket] = address(0);
        owners[_to] -= 1;
            
        emit TicketRefunded(_to, _ticket, msg.sender);
        return true;
    }
}