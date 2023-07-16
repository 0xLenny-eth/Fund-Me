// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    address immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Not the owner");
        _;
    }

    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50e18;

    address[] public funders;
    mapping(address funder=> uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() external onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
