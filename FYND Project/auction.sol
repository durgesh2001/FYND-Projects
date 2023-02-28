// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract AuctionPlatform {
    
    // structure to create auction

    struct Auction {
        uint auctionID;
        string description;
        uint startTime;
        uint endTime;
        uint minBidValue;
        address auctionOwner;
        uint highestBid;
        address highestBidder;
        bool closed;
        mapping(address => uint) bids;
    }
    
    mapping(uint => Auction) public auctions;
    mapping(address => uint[]) public bidsPlaced;
    mapping(uint => address[]) public biddersForAuction;
    //maps addresses to arrays of auctionIDs representing the auction where address place bids.
    mapping(address => uint[]) public bidsByBidder;
    
    uint public auctionCounter;

    //function to create new auctions
    
    function createAuction(string memory _description, uint _startTime, uint _endTime, uint _minBidValue) public {
        require(_startTime < _endTime, "End time must be after start time");
        auctionCounter++;
        Auction storage auction = auctions[auctionCounter];
        auction.auctionID = auctionCounter;
        auction.description = _description;
        auction.startTime = _startTime;
        auction.endTime = _endTime;
        auction.minBidValue = _minBidValue;
        auction.auctionOwner = msg.sender;
    }
    
    //function to place the bid of particular auction

    function placeBid(uint _auctionID) public payable {
        Auction storage auction = auctions[_auctionID];
        require(msg.value >= auction.minBidValue, "Bid value must be at least the minimum bid value");
        require(block.timestamp >= auction.startTime && block.timestamp <= auction.endTime, "Auction is not active");
        require(msg.sender != auction.auctionOwner, "Auction owner cannot place a bid");
        require(msg.value > auction.highestBid, "Bid value must be higher than current highest bid");
        
        if (auction.highestBidder != address(0)) {
            // Return previous highest bid to the bidder
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        
        auction.bids[msg.sender] = msg.value;
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        biddersForAuction[_auctionID].push(msg.sender);
        bidsPlaced[msg.sender].push(_auctionID);
    }

    // function for auction owner to see the list of all bids placed on their auction
    function getBids(uint _auctionId) public view returns (address[] memory, uint[] memory) {
        Auction storage auction = auctions[_auctionId];  //doubt
        uint len = 0;
        for (uint i = 0; i < bidsByBidder[auction.auctionOwner].length; i++) {
            if (bidsByBidder[auction.auctionOwner][i] == _auctionId) {
                len++;
            }
        }
        address[] memory addrs = new address[](len);
        uint[] memory values = new uint[](len);
        uint j = 0;
        for (uint i = 0; i < bidsByBidder[auction.auctionOwner].length; i++) {
            uint bidAuctionId = bidsByBidder[auction.auctionOwner][i];
            if (bidAuctionId == _auctionId) {
                addrs[j] = msg.sender;
                values[j] = auction.bids[msg.sender];
                j++;
            }
        }
        return (addrs, values);
    }
    

    
//function to get the bids of a particular 

    function getBidsPlaced() public view returns (uint[] memory) {
        return bidsPlaced[msg.sender];
    }
    
    //function to close the particular auction

    function closeAuction(uint _auctionID) public {
        Auction storage auction = auctions[_auctionID];
        require(msg.sender == auction.auctionOwner, "Only the auction owner can close the auction");
        require(block.timestamp > auction.endTime, "Auction has not ended yet");
        require(!auction.closed, "Auction has already been closed");
        
        auction.closed = true;
        payable(auction.auctionOwner).transfer(auction.highestBid);
    }
}
