// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./lib/YulDeployer.sol";

interface ERC20Yul {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20YulTest is Test {
    YulDeployer yulDeployer = new YulDeployer();

    ERC20Yul ERC20YulContract;

    function setUp() public {
        ERC20YulContract = ERC20Yul(
            yulDeployer.deployContract("ERC20Yul", "wvleak", "WVK", 18)
        );
    }

    // function testERC20Yul() public {
    //     bytes memory callDataBytes = abi.encodeWithSignature("randomBytes()");

    //     (bool success, bytes memory data) = address(ERC20YulContract).call{gas: 100000, value: 0}(callDataBytes);

    //     assertTrue(success);
    //     assertEq(data, callDataBytes);
    // }

    function test_Name() public {
        // bytes memory name = ERC20YulContract.name();
        // console.logBytes(name);
        console.log(ERC20YulContract.name());
    }

    function testDecimals() public {
        console.log(ERC20YulContract.decimals());
    }
}
