// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./lib/ERC721YulDeployer.sol";
import "./lib/ERC721Receiver.sol";

interface ERC721Yul {
    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool);

    // ERC165
    function supportsInterface(bytes4 interfaceID) external view returns (bool);

    function mint(address _to) external payable;
}

contract ERC721YulTest is Test {
    ERC721YulDeployer yulDeployer = new ERC721YulDeployer();

    ERC721Receiver receiver = new ERC721Receiver();

    ERC721Yul ERC721YulContract;

    function setUp() public {
        ERC721YulContract = ERC721Yul(yulDeployer.deployContract("ERC721Yul"));
    }

    function mint() internal {
        vm.prank(address(yulDeployer));
        ERC721YulContract.mint(address(this));
    }

    function test_mint() public {
        mint();
    }

    function test_balanceOf() public {
        mint();
        assertEq(ERC721YulContract.balanceOf(address(this)), 1);
    }

    function test_ownerOf() public {
        mint();
        assertEq(ERC721YulContract.ownerOf(0), address(this));
    }

    function test_transferFrom() public {
        mint();
        ERC721YulContract.transferFrom(address(this), address(yulDeployer), 0);
        assertEq(ERC721YulContract.ownerOf(0), address(yulDeployer));
    }

    function test_safeTransferFrom() public {
        mint();
        mint();
        ERC721YulContract.safeTransferFrom(address(this), address(receiver), 1);
    }
}
