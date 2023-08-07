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

    function mint(address _to) external payable returns (uint256);
}

contract ERC721YulTest is Test {
    ERC721YulDeployer yulDeployer = new ERC721YulDeployer();

    ERC721Receiver receiver = new ERC721Receiver();

    ERC721Yul ERC721YulContract;

    function setUp() public {
        ERC721YulContract = ERC721Yul(yulDeployer.deployContract("ERC721Yul"));
    }

    function mint() internal returns (uint256 _tokenId) {
        vm.prank(address(yulDeployer));
        _tokenId = ERC721YulContract.mint(address(this));
    }

    function test_mint() public {
        assertEq(mint(), 0);
    }

    function test_RevertMint_NotDeployer() public {
        vm.expectRevert();
        ERC721YulContract.mint(address(this));
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
        uint256 tokenId = mint();
        ERC721YulContract.transferFrom(
            address(this),
            address(yulDeployer),
            tokenId
        );
        assertEq(ERC721YulContract.ownerOf(0), address(yulDeployer));
    }

    function test_RevertTransferFrom() public {
        uint256 tokenId = mint();
        //not the owner
        vm.prank(address(receiver));
        vm.expectRevert();
        ERC721YulContract.transferFrom(
            address(this),
            address(yulDeployer),
            tokenId
        );
        //zero address
        vm.expectRevert();
        ERC721YulContract.transferFrom(address(this), address(0), tokenId);
        //not valid tokenId
        vm.expectRevert();
        ERC721YulContract.transferFrom(address(this), address(yulDeployer), 1);
    }

    function test_safeTransferFrom() public {
        uint256 tokenId = mint();
        ERC721YulContract.safeTransferFrom(
            address(this),
            address(receiver),
            tokenId
        );
    }

    function test_safeTransferFromWithData() public {
        uint256 tokenId = mint();
        ERC721YulContract.safeTransferFrom(
            address(this),
            address(receiver),
            tokenId,
            "test "
        );
    }

    function test_RevertsafeTransferFrom_NotERC721Receiver() public {
        uint256 tokenId = mint();
        vm.expectRevert();
        ERC721YulContract.safeTransferFrom(
            address(this),
            address(yulDeployer),
            tokenId
        );
    }

    function test_approve() public {
        uint256 tokenId = mint();
        ERC721YulContract.approve(address(receiver), tokenId);
        assertEq(ERC721YulContract.getApproved(tokenId), address(receiver));
    }

    function test_approved_transfers() public {
        uint256 tokenId = mint();
        ERC721YulContract.approve(address(receiver), tokenId);
        vm.prank(address(receiver));
        ERC721YulContract.transferFrom(
            address(this),
            address(yulDeployer),
            tokenId
        );
        assertEq(ERC721YulContract.ownerOf(tokenId), address(yulDeployer));
    }

    function test_setApprovalForAll() public {
        ERC721YulContract.setApprovalForAll(address(receiver), true);
        assertTrue(
            ERC721YulContract.isApprovedForAll(address(this), address(receiver))
        );
        ERC721YulContract.setApprovalForAll(address(receiver), false);
        assertFalse(
            ERC721YulContract.isApprovedForAll(address(this), address(receiver))
        );
    }

    function test_approvalForAll_transfers() public {
        uint256 firstTokenId = mint();
        uint256 secondTokenId = mint();

        ERC721YulContract.setApprovalForAll(address(receiver), true);
        vm.startPrank(address(receiver));
        ERC721YulContract.transferFrom(
            address(this),
            address(yulDeployer),
            firstTokenId
        );
        ERC721YulContract.transferFrom(
            address(this),
            address(yulDeployer),
            secondTokenId
        );
        assertEq(ERC721YulContract.ownerOf(firstTokenId), address(yulDeployer));
        assertEq(
            ERC721YulContract.ownerOf(secondTokenId),
            address(yulDeployer)
        );
    }

    function test_supportsInterface() public {
        assertTrue(ERC721YulContract.supportsInterface(0x80ac58cd)); // IERC721
        assertTrue(ERC721YulContract.supportsInterface(0x01ffc9a7)); //IERC165
    }
}
