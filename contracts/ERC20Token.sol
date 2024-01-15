pragma solidity ^0.8.20;

contract ERC20Token {
 string public name;
 string public symbol;
 uint256 public decimals;
 uint256 public totalsupply;

 mapping(address=>uint256)public balanceOf;
 mapping(address=>mapping(address=>uint256))public allowance;

 event Transfer(address from,address to,uint256 value);
 event Approve(address operator,address spender,uint256 value);

 constructor(string memory _name,string memory _sym){
    name=_name;
    symbol=_sym;
    decimals=18;
    totalsupply=10**9*10**18;
    balanceOf[msg.sender]=totalsupply;
    emit Transfer(address(0), msg.sender, totalsupply);


 }
 function _transfer(address from,address to,uint256 value)internal {
    require(to!=address(0),"invaild address");
    balanceOf[from]-=value;
    balanceOf[to]+=value;
    emit Transfer(from, to, value);
 }
 function _approve(address operator,address spender,uint256 value)internal {
    allowance[operator][spender]=value;
    emit Approve(operator, spender, value);
 }
 function transfer(address from,address to ,uint256 value)public returns(bool success){
    require(balanceOf[from]>=value);
    _transfer(from, to, value);
    return true;
 }
 function approve(address spender,uint256 value)public returns(bool success){
    _approve(msg.sender, spender, value);
    return true;
 }
 function transferfrom(address from,address to,uint256 value)public returns(bool success){
    require(balanceOf[from]>=value);
    require(allowance[from][msg.sender]>=value);
    _transfer(from, to, value);
    _approve(from, msg.sender, allowance[from][msg.sender]-value);
 }
}