pragma solidity ^0.4.18;

import "../common/AccessControl.sol";
import "../common/EventSettings.sol";
import "../common/WithdrawEtherControl.sol";

contract PayalableTicketsManagement is AccessControl, EventSettings, WithdrawEtherControl {
    mapping (address => uint) public owners;

    mapping (bytes32 => address) public allocatedTickets;
    mapping (bytes32 => address) public redeemedTickets;

    mapping (bytes32 => mapping (address => uint256)) public bookedTicketsPrice;
    mapping (bytes32 => uint256) public bookedTicketsExpiration;

    event TicketBooked(address _to, bytes32 _ticket,  uint256 _price);
    event TicketAllocated(address _to, bytes32 _ticket);
    event TicketRefunded(address _to, bytes32 _ticket);
    event TicketRedeemed(address _from, bytes32 _ticket);
    event TicketTransferred(address _from, address _to, bytes32 _ticket);

    function book(address _to, bytes32 _ticket, uint256 _price, uint _expiration)
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

        require(
            _expiration > block.timestamp && (
                bookedTicketsExpiration[_ticket] == 0x0 || 
                bookedTicketsExpiration[_ticket] < block.timestamp
            )
        );

        bookedTicketsPrice[_ticket][_to] = _price;
        bookedTicketsExpiration[_ticket] = _expiration;
        
        TicketBooked(_to, _ticket, _price);
        return true;
    }

    function buy(bytes32 _ticket) 
        isEventActive() 
        isSaleActive() 
        external 
        payable
        returns(bool status)
    {
        require(
            bookedTicketsExpiration[_ticket] < block.timestamp &&
            bookedTicketsPrice[_ticket][msg.sender] >= msg.value
        );

        require(
            allocatedTickets[_ticket] == address(0) && 
            redeemedTickets[_ticket] == address(0) 
        );

        balanceInEther[addressCT] = feeCT.mul(msg.value) / (1 ether);

        // balanceInEther[addressCT] = sub(mul(feeCT, msg.value), (1 ether));

        // balanceInEther[addressTS] = sub(mul(feeTS, msg.value), (1 ether));
        // balanceInEther[addressOG] = sub(mul(feeOG, msg.value), (1 ether));

        allocated++;
        allocatedTickets[_ticket] = msg.sender;
        owners[msg.sender] += 1;
            
        TicketAllocated(msg.sender, _ticket);
        return true;
    }

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
            
        TicketAllocated(_to, _ticket);
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

        TicketTransferred(msg.sender, _to, _ticket);
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

        TicketTransferred(_from, _to, _ticket);
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

        TicketRedeemed(_from, _ticket);
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
            
        TicketRefunded(_to, _ticket);
        return true;
    }
}