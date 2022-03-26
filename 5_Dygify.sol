// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract Invoice {

    address payable public seller; //seller variable to hold address of seller while making transactions and recieve.
    address payable public buyer; //buyer variable to hold address of seller while making transactions and recieve.

    //Structure of the invoice
    //parameters buyer PAN, seller PAN, amount transfered or recieved, reason for the transaction, status of transaction. 
    struct invoice {

        string BuyerPAN; //PAN number of buyer
        string SellerPAN; //PAN number of seller
        uint invoiceAmount; // Amount transfered
        string invoiceData; // Description of the transaction
        bool transaction_Status; // Status of transaction true--> success, false--> failed
    }

    //The number of invoice records user wants to view
    uint public count = 3;

    //Mapping of key::value
    mapping (string => invoice) public data;

    string[] public database; // array to store data

    mapping (address => uint) private balanceOf; //This is to check balance of seller or buyer

    //Constructor assigning buyer address
    constructor( address payable _buyeraddress) {

        buyer = _buyeraddress;
    }


    //Function to add invoice data manually.
    //choice 0-->buyer, 1-->seller
    function adding_invoice_data(uint role, string memory buyer_PAN, string memory seller_PAN, uint amount, string memory invoice_data, bool transfer_status) public returns(string memory ) {

        if (role == 0) {

            invoice storage inv = data[buyer_PAN];
            //invoice storage inv = invoice(buyer_PAN,seller_PAN,amount,invoice_data,transfer_status);

            inv.SellerPAN = seller_PAN;
            inv.BuyerPAN = buyer_PAN;
            inv.invoiceAmount = amount;
            inv.invoiceData = invoice_data;
            inv.transaction_Status = transfer_status;

            database.push(buyer_PAN);

            return "Buyer Done";

        }

        else {

            invoice storage inv = data[seller_PAN];
            //invoice storage inv =  invoice(buyer_PAN,seller_PAN,amount,invoice_data,transfer_status);//data[seller_PAN];

            inv.SellerPAN = seller_PAN;
            inv.BuyerPAN = buyer_PAN;
            inv.invoiceAmount = amount;
            inv.invoiceData = invoice_data;
            inv.transaction_Status = transfer_status;

            database.push(seller_PAN);
            return "Seller Done";

        }

    }


    //FAllback and Recieve function for external payment process.
    //When our balance is 0 transactions has to be done using these functions.
    fallback() external payable { balanceOf[buyer] -= msg.value; }

    receive() external payable { balanceOf[seller] += msg.value; } 

    
    //When buyer has sufficient balance in account for transaction
    //buyer can use this function to transfer payments to seller.
    //The owner of this function is only Buyer. 
    //If success then it will update the invoice.
    function buyerTransaction(uint _price, string memory _buyerPAN, string memory _sellerPAN, string memory _description) payable public {

        require(buyer == msg.sender);

        bool status = seller.send(_price);
        require(status, "Transaction Failed!");

        adding_invoice_data(0, _buyerPAN, _sellerPAN, _price, _description, status);

    }


    //When seller has sufficient balance in account for transaction
    //seller can use this function to transfer payments to buyer.
    //The owner of this function is only Seller. 
    //If success then it will update the invoice.
    function sellerTransaction(uint _price, string memory _buyerPAN, string memory _sellerPAN, string memory _description) payable public {

        require(seller == msg.sender);

        bool status = buyer.send(_price);
        require(status, "Transaction Failed!");

        adding_invoice_data(1, _buyerPAN, _sellerPAN, _price, _description, status);

    }


    //Function to get the last or recent transaction Invoice.
    //This function will take a PAN number of either buyer or seller.
    function lastTransactionInvoice(string memory pan) public view returns(invoice memory) {
        return data[pan];
    } 


    //Function to retrive all transaction invoices  as list by matching a PAN number.
    function getALL(string memory _PAN) public view returns(string[] memory, string[] memory, uint[] memory, string[] memory, bool[] memory) {


        string[] memory BuyerPAN = new string[](count);
        string[] memory SellerPAN = new string[](count);
        uint[] memory invoiceAmount = new uint[](count);
        string[] memory invoiceData = new string[](count);
        bool[] memory transaction_Status = new bool[](count);

        for(uint i=0; i < database.length; i++) {
            invoice storage _inv = data[_PAN];

            BuyerPAN[i] = _inv.BuyerPAN;
            SellerPAN[i] = _inv.SellerPAN;
            invoiceAmount[i] = _inv.invoiceAmount;
            invoiceData[i] = _inv.invoiceData;
            transaction_Status[i] = _inv.transaction_Status;

        }

        return (BuyerPAN, SellerPAN, invoiceAmount, invoiceData, transaction_Status);

    }


}