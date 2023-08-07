// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/console.sol";

contract ERC721Receiver {
    // function onERC721Received(
    //     address,
    //     address,
    //     uint256,
    //     bytes memory
    // ) public returns (bytes4) {
    //     console.log("entered");
    //     console.logBytes4(this.onERC721Received.selector);
    //     return this.onERC721Received.selector;
    // }
    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        console.log("entered");
        console.logBytes4(this.onERC721Received.selector);
        console.log(tokenId);
        console.logBytes(data);
        return this.onERC721Received.selector;
    }
}
