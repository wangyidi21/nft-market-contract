// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Market{
    IERC20 erc20;
    IERC721 erc721;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    
    constructor(address _erc20,address _erc721){
        require( _erc20!=address(0),"zero address");
        require( _erc721!=address(0),"zero address");
        erc20=IERC20(_erc20);
        erc721=IERC721(_erc721);
    }

    struct Order{
        address seller;
        uint256 tokenId;
        uint256 price;

    }
    

    mapping(uint256=>Order) public OrderOfId;
    Order[] public orders;
    mapping(uint256=>uint256) public idToOrderIndex;

    event Deal(address buyer,address seller,uint256 tokenId,uint256 price);
    event NewOrder(address seller,uint256 tokenId,uint256 price);
    event ChangePrice(address seller,uint256 tokenId,uint256 previousPrice,uint256 price);
    event deleteOrder(address seller,uint256 tokenId);


    function Buy(uint256 _tokenId)external {
    address seller=OrderOfId[_tokenId].seller;
    address buyer=msg.sender;
    uint256 price=OrderOfId[_tokenId].price;

    require( erc20.transferFrom(buyer, seller, price),"please take memony");
    erc721.safeTransferFrom(address(this), buyer, _tokenId);
    emit Deal(buyer,seller,_tokenId,price);
    }

    function cancelOrder(uint256 _tokenId)external{
    address seller=OrderOfId[_tokenId].seller;
    require( msg.sender==seller,"only seller");
    erc721.safeTransferFrom(address(this), seller, _tokenId);
    emit deleteOrder(seller, _tokenId);
    }

    function PriceChanged(uint256 _tokenId,uint256 newPrice)external {

    address seller=OrderOfId[_tokenId].seller;
    require( msg.sender==seller,"only seller");

    uint256 previousPrice=OrderOfId[_tokenId].price;
    Order storage order=orders[idToOrderIndex[_tokenId]];
    order.price=newPrice;
    emit ChangePrice(seller, _tokenId, previousPrice, newPrice);

    
    }

    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data)external returns(bytes4){
        require(operator==from,"Market: Seller must be operator");
        uint256 price=toUint256(data,0);
       createOrder(from, tokenId, price);
        return  MAGIC_ON_ERC721_RECEIVED;

    }

    function createOrder(address seller,uint256 tokenId,uint256 price)internal{
    require( price>=0,"the price should more than zero");
    orders.push(Order(seller,tokenId,price));
    OrderOfId[tokenId]=Order(seller,tokenId,price);
    idToOrderIndex[tokenId]=orders.length-1;
    emit NewOrder(seller, tokenId, price);
    }

     function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function removeOrder(uint256 _tokenId)internal {
    delete OrderOfId[_tokenId];
    uint256 index=idToOrderIndex[_tokenId];
    uint256 Lastindex=orders.length-1;
    if(index!=Lastindex){
    Order storage order=orders[Lastindex];
    orders[index]=order;
    idToOrderIndex[order.tokenId]=index;

    }
    orders.pop();
    
     
    }

    function getOrderLength() external view returns(uint256){
        return orders.length;
    }
    function getAllNFTs()external  view returns(Order[] memory){
        return orders;
    }
    function getMyNFTs()external view returns (Order[] memory){
        Order[] memory myOrders=new Order[](orders.length);
        uint256 account=0;
        for(uint256 i=0;i<orders.length;i++){
                if(msg.sender==orders[i].seller){
                    myOrders[account]=orders[i];
                    account++;
                }
        }
        return  myOrders;
    }

}