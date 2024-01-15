// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";


 

contract Market{
    IERC20 erc20;
    IERC721 erc721;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    constructor(address _erc20,address _erc721){
        require(_erc20!=address(0));
        require(_erc721!=address(0));
        erc20=IERC20(_erc20);
        erc721=IERC721(_erc721);

    }

    struct Order{
    address seller;
    uint256 tokenId;
    uint256 price;
    }

    mapping(uint256=>Order)public orderOfId;
    Order[] public orders;
    mapping(uint256=>uint256)public idOfOrderIndex;

    event Deal(address buyer,address seller,uint256 tokenId,uint256 price);
    event NewOrder(address seller,uint256 tokenId,uint256 price);
    event ChangePrice(address seller,uint256 tokenId,uint256 previousPrice,uint256 price);
    event deleteOrder(address seller,uint256 tokenId);

    function buy(uint256 _tokenId)external {
        address seller=orderOfId[_tokenId].seller;
        address buyer=msg.sender;
        uint256 price=orderOfId[_tokenId].price;
        require(erc20.transferFrom(buyer, seller, price),"please give money before");
        erc721.safeTransferFrom(address(this), buyer, _tokenId);
        //下架
        emit Deal(buyer, seller, _tokenId, price);

    }

    function PriceChanged(uint256 _tokenId,uint256 price)external {
        address seller=orderOfId[_tokenId].seller;
        require(msg.sender==seller,"only seller");
        uint256 previousprice=orderOfId[_tokenId].price;
        orderOfId[_tokenId].price=price;
        Order storage order=orders[idOfOrderIndex[_tokenId]];
        order.price=price;
        emit ChangePrice(seller, _tokenId, previousprice, price);
    }

    function CencleOrder(uint256 _tokenId)external {
        address seller=orderOfId[_tokenId].seller;
        require(msg.sender==seller,"only seller");
        erc721.safeTransferFrom(address(0), seller, _tokenId);
        emit deleteOrder(seller, _tokenId);
    }
    function onERC721Recive(address operator,address seller,uint256 tokenId,bytes calldata data)public returns(bytes4){
        require(operator==seller,"NFT requires operator equal seller");
        uint256 price=toUint256(data,0);
        piceOrder(seller, tokenId, price);
        return  MAGIC_ON_ERC721_RECEIVED;
    }

    function piceOrder(address seller,uint256 tokenId,uint256 price)internal {
        orders.push(Order(seller,tokenId,price));
        orderOfId[tokenId]=Order(seller,tokenId,price);
        idOfOrderIndex[tokenId]=orders.length-1;
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


    function removeOrder(uint256 _tokenId)external {
         delete orderOfId[_tokenId];
        uint256 index=idOfOrderIndex[_tokenId];
        uint256 LastIndex=orders.length-1;
        if(index!=LastIndex){
            Order memory order = orders[LastIndex];
            orders[index]=order;
            idOfOrderIndex[order.tokenId]=index;

        }
        orders.pop();
       
         
    }
    function getOrderLength()public returns(uint256){
        return orders.length;
    }
    function getAllNFT()public returns(Order[] memory){
        return orders;
    }
    function getMyNFT()public returns(Order[]memory){
        Order[] memory myorder=new Order[](orders.length);
        uint256 account=0;
        for(uint256 i=0;i<orders.length;i++){
            if(orders[i].seller==msg.sender){
                myorder[account]=orders[i];
                account++;
            }
        }
        return myorder;

    }

}