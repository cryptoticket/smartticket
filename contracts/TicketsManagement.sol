pragma solidity ^0.4.18;

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
        require(_to != address(0));
        require(
            allocatedTickets[_ticket] == address(0) && 
            redeemedTickets[_ticket] == address(0)
        );

        if (limitTotal > 0) {
            require(allocated < limitTotal);
        }
        if (limitPerHolder > 0) {
            require(owners[_to] < limitPerHolder);
        }

        allocated++;
        allocatedTickets[_ticket] = _to;
        owners[_to] += 1;
            
        TicketAllocated(_to, _ticket, msg.sender);
        return true;
    }

    function transfer(address _to, bytes32 _ticket) 
        isEventActive() 
        isSaleActive() 
        external 
        returns(bool status) 
    {
        require(_to != address(0) && _to != msg.sender);
        require(
            allocatedTickets[_ticket] == msg.sender && 
            redeemedTickets[_ticket] == address(0)
        );

        if (limitPerHolder > 0) {
            require(owners[_to] < limitPerHolder);
        }
        
        allocatedTickets[_ticket] = _to;
        owners[msg.sender] -= 1;
        owners[_to] += 1;

        TicketTransferred(msg.sender, _to, _ticket, msg.sender);
        return true;
    }

    function transferFrom(address _from, address _to, bytes32 _ticket) 
        onlyAdmin() 
        isEventActive() 
        isSaleActive() 
        external 
        returns(bool status) 
    {
        require(_to != address(0) && _from != address(0) && _to != _from);
        require(
            allocatedTickets[_ticket] == _from && 
            redeemedTickets[_ticket] == address(0)
        );

        if (limitPerHolder > 0) {
            require(owners[_to] < limitPerHolder);
        }

        allocatedTickets[_ticket] = _to;
        owners[_from] -= 1;
        owners[_to] += 1;

        TicketTransferred(_from, _to, _ticket, msg.sender);
        return true;
    }

    function redeem(address _from, bytes32 _ticket) 
        onlyAdmin() 
        isEventActive() 
        external 
        returns(bool status) 
    {
        require(_from != address(0));
        require(
            allocatedTickets[_ticket] == _from && 
            redeemedTickets[_ticket] == address(0)
        );

        redeemedTickets[_ticket] = _from;
        owners[_from] -= 1;

        TicketRedeemed(_from, _ticket, msg.sender);
        return true;
    }

    function refund(address _to, bytes32 _ticket) 
        onlyAdmin() 
        refundable() 
        external 
        returns(bool status) 
    {
        require(_to != address(0));
        require(
            allocatedTickets[_ticket] == _to && 
            redeemedTickets[_ticket] == address(0)
        );

        allocated--;
        allocatedTickets[_ticket] = address(0);
        owners[_to] -= 1;
            
        TicketRefunded(_to, _ticket, msg.sender);
        return true;
    }
}