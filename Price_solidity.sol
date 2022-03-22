// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract Productprice {


    address public marchent = msg.sender;
    address payable buyer = payable(msg.sender);
    uint256 public price;

    mapping (address => uint256) private balanceOf;

    modifier onlyBy(address _marchentname) {

        require(msg.sender == _marchentname);
        _;
    }


    constructor(uint _itemprice) onlyBy(marchent) {

        price = _itemprice;
    }

    function pricingProduct(uint _productprice) public onlyBy(marchent) returns(uint){

        price = _productprice;
        return price;
    }

    fallback() external payable { balanceOf[buyer] += msg.value; }

    receive() external payable { balanceOf[buyer] -= msg.value; } 



    function pay(uint _gaslimit, uint _gas_price_per_unit, uint _current_eth_gas_cost, address payable receiver) public payable returns(uint current_gas_fee, uint payable_total_cost) {

        current_gas_fee = _gaslimit * _gas_price_per_unit / 1000000000;
        payable_total_cost = current_gas_fee *  _current_eth_gas_cost + price;

        //require( msg.value <= payable_total_cost);
        require( balanceOf[buyer] > payable_total_cost);

        //balanceOf[ buyer ] -= payable_total_cost;
        //(bool payment_success, ) = marchent.call{value: payable_total_cost} ("");
        //require(payment_success, "Failed payment");

        receiver.transfer(payable_total_cost);

    }

    function withdraw(uint _withdrawMoney) public onlyBy(marchent) returns(uint) {

        if(_withdrawMoney <= balanceOf[marchent]) {

            balanceOf[marchent] -= _withdrawMoney;
            (bool status, ) = marchent.call{value: _withdrawMoney} ("");
            require(status, "Failed to withdraw..");
        }

        return balanceOf[marchent];

    }
}