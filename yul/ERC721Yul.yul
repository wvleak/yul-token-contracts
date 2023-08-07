/**
 * @title ERC721Yul.
 *
 * @notice This implements the ERC721 non-fungible token standard in pure Yul as stated in the eip-721 specification.
 * @notice the Spec is here: https://eips.ethereum.org/EIPS/eip-721
 * @author wvleak
 * @date August, 2023
 */

object "ERC721" {
    /**
    * @notice Constructor
    * @dev the parameters are encoded after the code. The storage variables are handled like in solidity
    * @param name The name of the ERC20 token
    * @param symbol The symbol of the ERC20 token
    * @param decimals The number of decimals of the ERC20 token
    */ 

    code {
        /** 
        * =============================================
        * STORAGE SLOTS
        * =============================================
        */
        function ownerSlot() -> p { p := 0 }  

        /* set owner (the deployer) */
        sstore(ownerSlot(), caller())


        /** 
        * =============================================
        * RETURN CONTRACT CODE
        * =============================================
        */
        datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
        return(0, datasize("Runtime"))

    }

    object "Runtime" {
        code {

            switch selector()
            case 0x70a08231 /* balanceOf(address) */{
                let owner := decodeAddress(0)
                returnUint(balanceOf(owner))

            }
            case 0x6352211e /* ownerOf(uint256) */{
                let tokenId := decodeUint(0)
                returnUint(ownerOf(tokenId))

            }
            case 0xb88d4fde /* safeTransferFrom(address, address, uint256, bytes) */ {
                let from := decodeAddress(0)
                let to := decodeAddress(1)
                let tokenId := decodeUint(2)

                //CHECKS
                require(validId(tokenId))
                require(or(calledByOwner(tokenId), calledByAuthorizedOperator(tokenId, ownerOf(tokenId), caller())))
                require(isOwner(from, tokenId))

                //EFFECTS
                //
                //update owners mapping
                sstore(mappingValueSlot(tokenId, ownersSlot()), to)
                //update balances mapping
                let lastBalanceFrom := sload(mappingValueSlot(from, balancesSlot()))
                sstore(mappingValueSlot(from, balancesSlot()), sub(lastBalanceFrom, 1))
                let lastBalanceTo := sload(mappingValueSlot(to, balancesSlot()))
                sstore(mappingValueSlot(to, balancesSlot()), add(lastBalanceTo, 1))
                //reset approvals
                sstore(mappingValueSlot(tokenId, tokenApprovalsSlot()), 0)

                //INTERACTION
                if gt(extcodesize(to), 0){
                    // store the function selector onERC721Received(address,address,uint256,bytes) with arguments
                    let fmp := mload(0x40)
                    mstore(fmp, 0x150b7a02)
                    mstore(add(fmp, 0x20), from) 
                    mstore(add(fmp, 0x40), to) 
                    mstore(add(fmp, 0x60), tokenId)
                    // update free memory pointer
                    mstore(0x40, add(fmp, 0x80)) 
                    // call onERC721Received
                    let success := call(gas(), to, 0, add(fmp, 28), decodeBytes(3), 0x00, 0x20)
                    if iszero(success) {
                        revert(0,0)
                    }
                    //check returned value to be `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
                    if iszero(eq(mload(0), 0x150b7a02)) {
                        revert(0,0)
                    }
                }

                //EVENTS
                emitApproval(ownerOf(tokenId), 0, tokenId)
                emitTransfer(from, to, tokenId)

            }
            case 0x42842e0e /* safeTransferFrom(address, address, uint256) */{
                let from := decodeAddress(0)
                let to := decodeAddress(1)
                let tokenId := decodeUint(2)

                //CHECKS
                require(validId(tokenId))
                require(or(calledByOwner(tokenId), calledByAuthorizedOperator(tokenId, ownerOf(tokenId), caller())))
                require(isOwner(from, tokenId))

                //EFFECTS
                //
                //update owners mapping
                sstore(mappingValueSlot(tokenId, ownersSlot()), to)
                //update balances mapping
                let lastBalanceFrom := sload(mappingValueSlot(from, balancesSlot()))
                sstore(mappingValueSlot(from, balancesSlot()), sub(lastBalanceFrom, 1))
                let lastBalanceTo := sload(mappingValueSlot(to, balancesSlot()))
                sstore(mappingValueSlot(to, balancesSlot()), add(lastBalanceTo, 1))

                //INTERACTION
                if gt(extcodesize(to), 0){
                    // store the function selector onERC721Received(address,address,uint256,bytes) with arguments
                    let fmp := mload(0x40)//0x80
                    //mstore(0x40, fmp)

                    mstore(fmp, 0x150b7a02)
                    mstore(add(fmp, 0x20), from) 
                    mstore(add(fmp, 0x40), to) 
                    mstore(add(fmp, 0x60), tokenId)
                    mstore(add(fmp, 0x80), add(fmp, 0xa0))
                    //mstore(0x40, add(fmp, 0x80)) 
                    let success := staticcall(gas(), to, add(fmp, 28), 0xd0/*add(0x04, mul(0x20, 3))*/, 0, 0x20)
                    require(success)
                    //check returned value to be `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
                    if iszero(eq(shr(224, mload(0)), 0x150b7a02)) {
                        revert(0,0)
                    }
                }

                //EVENTS
                emitApproval(ownerOf(tokenId), 0, tokenId)
                emitTransfer(from, to, tokenId)
            }

            case 0x23b872dd /* transferFrom(address, address, uint256) */{
                let from := decodeAddress(0)
                let to := decodeAddress(1)
                let tokenId := decodeUint(2)

                //CHECKS
                require(validId(tokenId))
                require(or(calledByOwner(tokenId), calledByAuthorizedOperator(tokenId, ownerOf(tokenId), caller())))
                require(isOwner(from, tokenId))

                //EFFECTS
                //
                //update owners mapping
                sstore(mappingValueSlot(tokenId, ownersSlot()), to)
                //update balances mapping
                let lastBalanceFrom := sload(mappingValueSlot(from, balancesSlot()))
                sstore(mappingValueSlot(from, balancesSlot()), sub(lastBalanceFrom, 1))
                let lastBalanceTo := sload(mappingValueSlot(to, balancesSlot()))
                sstore(mappingValueSlot(to, balancesSlot()), add(lastBalanceTo, 1))

                //EVENTS
                emitApproval(ownerOf(tokenId), 0, tokenId)
                emitTransfer(from, to, tokenId)
            }

            case 0x095ea7b3 /* approve(address,uint256) */{
                let to := decodeAddress(0)
                let tokenId := decodeUint(1)
            
                require(or(calledByOwner(tokenId), authorized(ownerOf(tokenId), caller())))

                // update tokenApprovals mapping
                sstore(mappingValueSlot(tokenId, tokenApprovalsSlot()), to)

                emitApproval(ownerOf(tokenId), to, tokenId)
            }

            case 0xa22cb465 /* setApprovalForAll(address,bool) */{
                let operator := decodeAddress(0)
                let approval := decodeUint(1)

                // update operatorApprovals mapping
                sstore(nestedMappingValueSlot(caller(), operator, operatorApprovalsSlot()), approval)

                emitApprovalForAll(caller(), operator, approval)
            }

            case 0x081812fc /* getApproved(uint256) */{
                let tokenId := decodeUint(0)

                require(validId(tokenId))

                returnUint(approved(tokenId))
            }

            case 0xe985e9c5 /* isApprovedForAll(address,address) */{
                let owner := decodeAddress(0)
                let operator := decodeAddress(1)

                returnUint(authorized(owner, operator))
            }
            case 0x6a627842 /* mint(address) */{
                // // Only deployer check
                // if iszero(eq(caller(), deployer())){
                //     revert(0,0)
                // }
                require(calledByDeployer())

                let to := decodeAddress(0)
                // get tokenId
                let tokenId := tokenCounter()
                // update owners mapping
                sstore(mappingValueSlot(tokenId, ownersSlot()), to)
                // update balances mapping
                let lastBalance := sload(mappingValueSlot(to, balancesSlot()))
                sstore(mappingValueSlot(to, balancesSlot()), add(lastBalance, 1))
                // update tokenCounter
                sstore(tokenCounterSlot(), safeAdd(tokenId, 1))

                emitTransfer(0, to, tokenId)

            }
            ///@dev See ERC165 interface
            case 0x01ffc9a7 /* supportsInterface(bytes4) */{
                let interfaceId := decodeUint(0)
                let ERC721InterfaceId := 0x80ac58cd
                let ERC165InterfaceId := 0x01ffc9a7
                returnUint(or(eq(interfaceId, ERC721InterfaceId), eq(interfaceId, ERC165InterfaceId)))
            }

            default {
                revert(0,0)
            }



    /** 
     * =============================================
     * STORAGE SLOTS
     * =============================================
     */

        function deployerSlot() -> p { p := 0 }
        function tokenCounterSlot() -> p { p := 1 } 
        // function nameSlot() -> p { p := 1 } For IERC721-Metadata implementation
        // function symbolSlot() -> p { p := 2 }
        function ownersSlot() -> p { p := 4 } // mapping(uint256=>address) from token ID to owner address
        function balancesSlot() -> p { p := 5 } // mapping(address=>uint256) from owner address to token count
        function tokenApprovalsSlot() -> p { p := 6 } // mapping(uint256=>address) from token ID to approved address
        function operatorApprovalsSlot() -> p { p := 7 } // mapping(address=>mapping(address=>bool)) from owner to operator approvals

    /** 
     * =============================================
     * GETTERS
     * =============================================
     */ 

        function deployer() -> d {
            d := sload(deployerSlot())
        }

        function tokenCounter() -> c {
            c := sload(tokenCounterSlot())
        }

        function balanceOf(_owner) -> b {
            b := sload(mappingValueSlot(_owner, balancesSlot()))
        }
        function ownerOf(_tokenId) -> o {
            o := sload(mappingValueSlot(_tokenId, ownersSlot()))
            revertIfZeroAddress(o) // NFTs assigned to zero address are considered invalid, and queries about them do throw.
        }
        function approved(_tokenId) -> a {
            a := sload(mappingValueSlot(_tokenId, tokenApprovalsSlot()))
        }
        function authorized(_owner, _operator) -> au {
            au := sload(nestedMappingValueSlot(_owner, _operator, operatorApprovalsSlot()))
        }

            


    /** 
     * =============================================
     * EVENTS
     * =============================================
     */ 

        //event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId)
        function emitTransfer(_from, _to, _tokenId) {
            log4(
                0,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, // keccak256("Transfer(address,address,uint256)")
                _from,
                _to,
                _tokenId
            )
        }  

        //event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId)
        function emitApproval(_owner, _approved, _tokenId) {
            log4(
                0,
                0,
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, // keccak256("Approval(address,address,uint256)")
                _owner,
                _approved,
                _tokenId
            )
        }

        //event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
        function emitApprovalForAll(_owner, _operator, _approved) {
            mstore(0, _approved)
            log3(
                0,
                0x20,
                0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31, // keccak256("ApprovalForAll(address,address,bool)")
                _owner,
                _operator
            )
        }

    /** 
     * =============================================
     * HELPERS
     * =============================================
     */

        function selector() -> s {
            s := shr(224, calldataload(0))
        }       

        /// @dev get the slot where is stored the balance
        function mappingValueSlot(key, mappingSlot) -> slot {
            mstore(0, key)
            mstore(0x20, mappingSlot)
            slot := keccak256(0, 0x40)
        }

        /// @dev get the slot where is stored the allowance
        /// @return pos keccak256(_spender.keccak256(_owner.allowanceSlot))
        function nestedMappingValueSlot(key1, key2, mappingSlot) -> slot {
            // nested mapping
            mstore(0, key1)
            mstore(0x20, mappingSlot)
            let p := keccak256(0, 0x40)
            mstore(0, key2)
            mstore(0x20, p)
            slot := keccak256(0, 0x40)

        }

        function decodeAddress(offset) -> addr {
            addr := decodeUint(offset)
            revertIfZeroAddress(addr)
        }    

        function decodeUint(offset) -> i {
            i := calldataload(add(0x04, mul(offset, 0x20)))
        }

        function decodeBytes(offset) -> moffset {
            let fmp := mload(0x40)
            let bytesLength := calldataload(add(0x04, mul(offset, 0x20)))
            mstore(fmp, bytesLength)
            let word
            if eq(mod(bytesLength, 0x20), 0) {
                    word := div(bytesLength, 0x20)
                }
            if iszero(eq(mod(bytesLength, 0x20), 0)){
                word := add(div(bytesLength, 0x20), 1)
            }
            // Store the string in memory
            for { let i := 0 } lt(i, word) { i := add(i, 1) }
            {
                mstore(
                    add(fmp, mul(0x20, add(i, 1))),
                    calldataload(add(add(0x04, mul(offset, 0x20)), mul(0x20, add(i, 1))))
                )
            }
            //update free memory pointer
            mstore(0x40, add(fmp, mul(0x20, add(word, 2))))
            moffset := mload(0x40)
        }           
      
        function returnUint(value) {
            let fmp := mload(0x40)
            mstore(fmp, value)
            return(fmp, 0x20)
        }

        function returnTrue() {
            mstore(0, 1)
            return(0, 0x20)
        }
        

    /** 
     * =============================================
     * UTILITY FUNCTIONS
     * =============================================
     */

        // @dev Check for overflow
        function safeAdd(a, b) -> value {
            value := add(a, b)
            if or(lt(value, a), lt(value, b)){
                revert(0,0)
            }
        }

        function revertIfZeroAddress(addr) {
            if iszero(addr) {
                revert(0,0)
            }
        }
        function calledByDeployer() -> cbd {
                cbd := eq(deployer(), caller())
            }
        function calledByOwner(_tokenId) -> cbo {
                cbo := eq(ownerOf(_tokenId), caller())
            }
        function calledByAuthorizedOperator(_tokenId, _owner, _operator) -> op {
            op := or(eq(approved(_tokenId), caller()), authorized(_owner, _operator))
            
        }
        function validId(_tokenId) -> isValid {
            isValid := lt(_tokenId, tokenCounter())
        } 
        function isOwner(_from, _tokenId) -> io {
            io := eq(_from, ownerOf(_tokenId))
        }  

        function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }


        }
    }
}