// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INIT_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if(block.chainid == 11155111)
            activeNetworkConfig = getSepoliaEthConfig();
        else
            activeNetworkConfig = getOrCreateAnvilEthConfig();
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0))
            return activeNetworkConfig;
        vm.startBroadcast();
        MockV3Aggregator priceFeed = new MockV3Aggregator(DECIMALS, INIT_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory config = NetworkConfig(address(priceFeed));
        return config;
    }
}