// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Why is this a library and not abstract?
// Why not an interface?
// library PriceConverter {
//     // We could make this public, but then we'd have to deploy it
//     function getPrice() internal view returns (uint256) {
//         // Sepolia ETH / USD Address
//         // https://docs.chain.link/data-feeds/price-feeds/addresses
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(
//             0x694AA1769357215DE4FAC081bf1f309aDC325306
//         );
//         (, int256 answer, , , ) = priceFeed.latestRoundData();
//         // ETH/USD rate in 18 digit
//         return uint256(answer * 10000000000);
//     }

//     // 1000000000
//     function getConversionRate(
//         uint256 ethAmount
//     ) internal view returns (uint256) {
//         uint256 ethPrice = getPrice();
//         uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
//         // the actual ETH/USD conversion rate, after adjusting the extra 0s.
//         return ethAmountInUsd;
//     }
// }

// // here @chainlink is basically a library that handles all chainlink contracts directly
// // what happens is remix runs npm install @chainlink/contracts to get this library
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Libraris can't have state variables and all functions are marked internal
library PriceConvertor {
    function getPrice() internal view returns (uint256) {
        // address 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        // ABI? for this we use interface we use npm install @chainlink/contracts
        // 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419

        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        // latestRoundData returns
        // uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound
        // so we have to use pipes to get them
        // (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        // we can get only the one we need while without removing the commas,
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // will return 200000000 2000.00000000  because solidity don't work with decibals
        // answer is int256 while msg.value is uint256
        // so we'll have to convert answer into uint256
        // not all types can be typecasted while int and uint can be
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();

        // you always have to multiple before you divide
        // 1/2 = 0 because solidity doesnt understand decibals because it works on deterministic values like whole numbers
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        // 1e18 * 1e18 = soo big amount / 1e18 = 1e18

        return ethAmountInUsd;
    }
}
