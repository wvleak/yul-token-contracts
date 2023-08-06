object "ERC721" {
    code {
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

            }
            case 0x6352211e /* ownerOf(uint256) */{

            }
            case 0xb88d4fde /* safeTransferFrom(address, address, uint256, bytes) */ {

            }
            case 0x42842e0e /* safeTransferFrom(address, address, uint256) */{

            }
            case 0x23b872dd /* transferFrom(address, address, uint256) */{

            }
            case 0x095ea7b3 /* approve(address,uint256) */{

            }
            case 0xa22cb465 /* setApprovalForAll(address,bool) */{

            }
            case 0x081812fc /* getApproved(uint256) */{

            }
            case 0xe985e9c5 /* isApprovedForAll(address,address) */{

            }
            case 0x6a627842 /* mint(address) */{

            }
            ///@dev See ERC165 interface
            case 0x01ffc9a7 /* supportsInterface(bytes4) */{
                
            }
            default {
                revert(0,0)
            }

            


    /** 
     * =============================================
     * EVENTS
     * =============================================
     */ 

        //event Transfer(address indexed _from, address indexed _to, uint256 _value)
        function emitTransfer(_from, _to, _value) {
            mstore(0, _value)
            log3(
                0,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, // keccak256("Transfer(address,address,uint256)")
                _from,
                _to
            )
        }  

        //event Approval(address indexed _owner, address indexed _spender, uint256 _value)
        function emitApproval(_owner, _spender, _value) {
            mstore(0, _value)
            log3(
                0,
                0x20,
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, // keccak256("Approval(address,address,uint256)")
                _owner,
                _spender
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
        function balancePos(value) -> slot {
            mstore(0, value)
            mstore(0x20, balanceSlot())
            slot := keccak256(0, 0x40)
        }

        /// @dev get the slot where is stored the allowance
        /// @return pos keccak256(_spender.keccak256(_owner.allowanceSlot))
        function allowancePos(_owner, _spender) -> slot {
            // nested mapping
            mstore(0, _owner)
            mstore(0x20, allowanceSlot())
            let p := keccak256(0, 0x40)
            mstore(0, _spender)
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


        }
    }
}