// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./lib/YulDeployer.sol";

interface ERC20Yul {
    function owner() external view returns (address);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function mint(address, uint256) external; // Only owner can invoke

    function allowance(address, address) external returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract ERC20YulTest is Test {
    YulDeployer yulDeployer = new YulDeployer();

    ERC20Yul ERC20YulContract;

    function setUp() public {
        ERC20YulContract = ERC20Yul(
            yulDeployer.deployContract(
                "ERC20Yul",
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                //"wvleak",
                //"WVK",
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                18
            )
        );
    }

    // function testERC20Yul() public {
    //     bytes memory callDataBytes = abi.encodeWithSignature("randomBytes()");

    //     (bool success, bytes memory data) = address(ERC20YulContract).call{gas: 100000, value: 0}(callDataBytes);

    //     assertTrue(success);
    //     assertEq(data, callDataBytes);
    // }
    function testGetOwner() public {
        console.log(ERC20YulContract.owner());
    }

    function testGetName() public {
        // bytes memory name = ERC20YulContract.name();
        // console.logBytes(name);
        console.log(ERC20YulContract.name());
    }

    function testGetSymbol() public {
        console.log(ERC20YulContract.symbol());
    }

    function testGetDecimals() public {
        console.log(ERC20YulContract.decimals());
    }

    function testMint() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 1);
    }

    function testGetBalanceOf() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 10);
        console.log(ERC20YulContract.balanceOf(address(this)));
    }

    function testTransfer() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 10);
        console.log(ERC20YulContract.balanceOf(address(this)));
        ERC20YulContract.transfer(address(yulDeployer), 5);
        console.log(ERC20YulContract.balanceOf(address(yulDeployer)));
    }

    function testGetAllowance() public {
        console.log(
            ERC20YulContract.allowance(address(this), address(yulDeployer))
        );
    }

    function testApprove() public {
        ERC20YulContract.approve(address(yulDeployer), 20);
        console.log(
            ERC20YulContract.allowance(address(this), address(yulDeployer))
        );
    }

    function testTransferFrom() public {
        console.log(ERC20YulContract.balanceOf(address(yulDeployer)));
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 30);
        console.log(
            ERC20YulContract.allowance(address(this), address(yulDeployer))
        );
        ERC20YulContract.approve(address(yulDeployer), 20);
        console.log(
            ERC20YulContract.allowance(address(this), address(yulDeployer))
        );
        vm.prank(address(yulDeployer));
        ERC20YulContract.transferFrom(address(this), address(yulDeployer), 15);
        console.log(ERC20YulContract.balanceOf(address(yulDeployer)));
        console.log(
            ERC20YulContract.allowance(address(this), address(yulDeployer))
        );
    }
}
