//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


//import the ERC721 token from the openzeppelin library.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PaintingMarketplace is ERC721 {
    uint public paintingCounter;
    address payable public owner;   

    //define structure for assest (for example - painting).
    struct Painting {
        uint paintingID;
        string name;
        string description;
        uint price;
        address payable seller;
        bool issold;
    }
// mapping to store the paintings with a unique number  
    mapping(uint => Painting) public paintings;

//  event when painting is listed
    event PaintingListed(uint256 indexed paintingID, address indexed owner);

// event if painting is sold.

    event PaintingSold(uint256 indexed paintingID, address indexed buyer, uint256 price);

// modifier to restrict access only to the owner of the contract
modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() ERC721("Painting Token", "PNT"){
        paintingCounter = 0;
        owner = payable(msg.sender);
    }
    uint256 public listingPrice = 0.0001 ether;

// define a function for selling a painting

    function listPainting(string memory _name, string memory _description, uint _price) public {
        require(_price > 0, "Price must be greater than zero");
        paintingCounter++;
        Painting storage painting = paintings[paintingCounter];
        painting.paintingID = paintingCounter;
        painting.name = _name;
        painting.description = _description;
        painting.price = _price;
        painting.seller = payable(msg.sender);
        painting.issold = false;
        emit PaintingListed(painting.paintingID, msg.sender);
    }

//  function for buying a painting.   


    function buyPainting(uint _paintingID) public payable {
        Painting storage painting = paintings[_paintingID];
        require(!painting.issold, "Painting has already been sold");
        require(msg.value == painting.price, "Incorrect amount sent");
        
        painting.issold = true;
        _mint(msg.sender, _paintingID);
        painting.seller.transfer(painting.price);
        emit PaintingSold(_paintingID, msg.sender, painting.price);
    }

 //function to get the IDs of all unsold paintings

    function getPaintings() public view returns (uint[] memory) {
        uint[] memory paintingIDs = new uint[](paintingCounter);
        uint count = 0;
        
        for (uint i = 1; i <= paintingCounter; i++) {
            if (!paintings[i].issold) {
                paintingIDs[count] = i;
                count++;
            }
        }
        
        uint[] memory result = new uint[](count);
        for (uint i = 0; i < count; i++) {
            result[i] = paintingIDs[i];
        }
        
        return result;
    }

//function for current owner of the painting with given ID
    function getOwnerOfPainting(uint _paintingID) public view returns (address) {
        return ownerOf(_paintingID);
    }
// function to get details of a painting with the given ID
    function getPaintingDetails(uint _paintingID) public view returns (string memory, string memory, uint) {
        return (paintings[_paintingID].name, paintings[_paintingID].description, paintings[_paintingID].price);
    }

}