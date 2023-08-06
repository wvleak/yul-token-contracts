// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./lib/ERC20YulDeployer.sol";

interface ERC20Yul {
    function owner() external view returns (address);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function mint(address, uint256) external;

    function allowance(address, address) external returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract ERC20YulTest is Test {
    ERC20YulDeployer yulDeployer = new ERC20YulDeployer();

    ERC20Yul ERC20YulContract;
    string name = "testToken";
    string symbol = "TST";

    function setUp() public {
        ERC20YulContract = ERC20Yul(
            yulDeployer.deployContract("ERC20Yul", name, symbol, 18)
        );
    }

    /* ----- Test deployment ----- */
    function test_Init() public {
        assertEq(ERC20YulContract.owner(), address(yulDeployer));
        assertEq(ERC20YulContract.name(), name);
        assertEq(ERC20YulContract.symbol(), symbol);
        assertEq(ERC20YulContract.decimals(), 18);
    }

    /* ----- Test getter functions ----- */
    function test_GetBalanceOf() public {
        assertEq(ERC20YulContract.balanceOf(address(this)), 0);
    }

    function test_GetTotalSupply() public {
        assertEq(ERC20YulContract.totalSupply(), 0);
    }

    function test_GetAllowance() public {
        assertEq(
            ERC20YulContract.allowance(address(this), address(yulDeployer)),
            0
        );
    }

    /* ----- Test main functions ----- */
    function test_Mint() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 10);
        assertEq(ERC20YulContract.balanceOf(address(this)), 10);
    }

    function test_MintRevert_NotOwner() public {
        vm.expectRevert();
        ERC20YulContract.mint(address(this), 10);
    }

    function test_TotalSupplyIncrease() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 10);
        assertEq(ERC20YulContract.totalSupply(), 10);
    }

    function test_Approve() public {
        ERC20YulContract.approve(address(yulDeployer), 20);
        assertEq(
            ERC20YulContract.allowance(address(this), address(yulDeployer)),
            20
        );
    }

    function test_Transfer() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 10);
        // check balance before
        assertEq(ERC20YulContract.balanceOf(address(this)), 10);
        assertEq(ERC20YulContract.balanceOf(address(yulDeployer)), 0);

        ERC20YulContract.transfer(address(yulDeployer), 5);

        //check balance after
        assertEq(ERC20YulContract.balanceOf(address(this)), 5);
        assertEq(ERC20YulContract.balanceOf(address(yulDeployer)), 5);
    }

    function test_TransferRevert_InsufficiantBalance() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 10);

        vm.expectRevert();
        ERC20YulContract.transfer(address(yulDeployer), 15);
    }

    function test_TransferFrom() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 30);
        ERC20YulContract.approve(address(yulDeployer), 20);

        //check balance before
        assertEq(ERC20YulContract.balanceOf(address(this)), 30);
        assertEq(ERC20YulContract.balanceOf(address(yulDeployer)), 0);

        vm.prank(address(yulDeployer));
        ERC20YulContract.transferFrom(address(this), address(yulDeployer), 15);

        //check balance after
        assertEq(ERC20YulContract.balanceOf(address(this)), 15);
        assertEq(ERC20YulContract.balanceOf(address(yulDeployer)), 15);
    }

    function test_TransferFromRevert_InsuficientAllowance() public {
        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 30);
        ERC20YulContract.approve(address(yulDeployer), 10);

        vm.prank(address(yulDeployer));
        vm.expectRevert();
        ERC20YulContract.transferFrom(address(this), address(yulDeployer), 15);
    }

    function test_AllowanceDecrease() public {
        uint256 allowance = 20;
        uint256 transferAmount = 15;

        vm.prank(address(yulDeployer));
        ERC20YulContract.mint(address(this), 30);
        ERC20YulContract.approve(address(yulDeployer), allowance);

        //check allowance before
        assertEq(
            ERC20YulContract.allowance(address(this), address(yulDeployer)),
            20
        );

        vm.prank(address(yulDeployer));
        ERC20YulContract.transferFrom(
            address(this),
            address(yulDeployer),
            transferAmount
        );

        //check allowance after
        assertEq(
            ERC20YulContract.allowance(address(this), address(yulDeployer)),
            allowance - transferAmount
        );
    }
}
