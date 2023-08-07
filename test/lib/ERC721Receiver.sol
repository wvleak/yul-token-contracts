// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/console.sol";

contract ERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
