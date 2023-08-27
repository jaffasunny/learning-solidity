// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConvertor} from "./PriceConvertor.sol";

// Custom errors saves us gas because require and strings are gas heavy
error NotOwner();

contract FundMe {
    // uint256 public myValue = 1;
    // uint256 public minmumUsd = 5;

    // to attach the functions from our price convertor library to uint256
    using PriceConvertor for uint256;

    // uint256 public minmumUsd = 1e18;

    // If we know that our variable is not changing all over our contract or is having a static value 
    // we should make it a constant variable and change it's name to uppercase with _ in between
    // using constant variable makes our contract gas efficient
    // so by this we spend less gas if we use constant variable
    uint256 public constant MINIMUM_USD = 1e18;

    address[] public funders;
    // to look how much money each funder has sent we will use mapping
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // An owner will get assigned 
    // so that our withdraw function can be called by the owner
    // address public owner;

    // variable that we set only one time in a constructor or outside the same line we declare them
    // we use call them immutable variables and typical convention is to use i_ infront of variable name
    // this also makes our contract gas efficient
    address public immutable i_owner;
    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable  {
        // allow users to send $
        // Have a minimum $sent
        // 1. How do we sned ETH to this contract
        // the value field in our remix is the amount of native amount of our blockchain currency
        // first we have to allow our block chain to accept our currency by making the function "payable"
        // global keywords msg.value
        // which is the number of wei sent with msg

        // if this transaction fails on *require line then this myValue will get also reverted to its original value of 1
        // myValue = myValue + 2;

        // if we want to force user to send number of ethers then we use require
        // require(msg.value > 1e18, "didn't send enough eth"); // e=0 e18 means 18 zeros

        // we'd need an oracle to convert our msg.value eth to usd
        // Blockchain Oracle: Any device that interacts with the off-chain world to provide
        // external data or computation to smart contracts.
        // require(
        //     getConversionRate(msg.value) >= minmumUsd,
        //     "didn't send enough eth"
        // ); // e=0 e18 means 18 zeros

        // coming from library
         require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        
//  require(
//             msg.value >= minmumUsd, "didn't send enough eth");
         


        // What is a revert?
        // undo any actions that have been done and send the remaining gas back

        // If you send a failed transaction then we still have to spend gas for the lines that have
        // been executed and not for the one that failed

        // Block chain is dumb as they are deterministic systems and don't know any information outside of blockchain
        // for the outside information we use some centralised platforms like Chainlink

        // msg.sender gets us the address of the sender
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // Modifiers
    modifier onlyOwner {
        // this will stick the onlyOwner function before calling the function
        // the require keyword is not gas efficient
        // require(msg.sender == i_owner, "Sender is not Owner!");

        // This is gas efficient because we don't have to store and emit a long string in our case was "Sender is not Owner!"
        if (msg.sender != i_owner) revert NotOwner();

        // and then this line will tell whatever contents are in the function to be called next
        _;

        // the order of your _; matters
    }

    function withdraw() public onlyOwner{
        // check if it's owner
        // require(msg.sender == owner, "Must be owner!"); 

        // for loop
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset the array
        funders = new address[](0);

        // withdraw funds

        // transfer
        // msg.sender is of type address
        // payable(msg.sender) is of type payable
        // transfer automatically reverts
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // send will only revert if the transaction is made require
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send Failed");
        
        // call   
        // it is a lower level command and very powerful
        // to call virtually any function with all of the ethereum without having ABI

        // (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call Failed!");
    }    


    // If someone sends us money without using the fund function 
    // like in remix from the low level Interactions CALL DATA
    // then the below functions will be called
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
