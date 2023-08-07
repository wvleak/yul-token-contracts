/**
 * @title ERC20Yul.
 *
 * @notice This implements the ERC20 token standard in pure Yul as stated in the eip-20 specification.
 * @notice the Spec is here: https://eips.ethereum.org/EIPS/eip-20
 * @author wvleak
 * @date August, 2023
 */

object "ERC20" {
  /**
   * @notice Constructor
   * @dev the arguments are appended at the end of the contract's code. The storage variables are handled like in solidity
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
    function nameSlot() -> p { p := 1 }
    function symbolSlot() -> p { p := 2 }
    function decimalSlot() -> p { p := 3 }    


    /** 
     * =============================================
     * GET ARGUMENTS
     * =============================================
     */
    codecopy(0, datasize("ERC20"), sub(codesize(), datasize("ERC20"))) // encoded after the contract's code 

    let nameOffset := mload(0)
    let symbolOffset := mload(0x20)
    let decimalsOffset := 0x40 // appears after both string offsets

    /** 
     * =============================================
     * SET IN STORAGE
     * =============================================
     */

    /* set owner (the deployer) */
    sstore(ownerSlot(), caller())

    /* set name */
    setString(nameOffset, nameSlot())

    /* set symbol */
    setString(symbolOffset, symbolSlot())

    /* set decimals */
    sstore(decimalSlot(), mload(decimalsOffset))

    /** 
     * =============================================
     * RETURN CONTRACT CODE
     * =============================================
     */
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))

    /** 
     * =============================================
     * HELPERS
     * =============================================
     */

    function getStringLocation(slot) -> l {
        mstore(0, slot)
        l := keccak256(0, 0x20)
    }  

    function setString(offset, slot) {
        let stringLength := mload(offset)
        if lt(stringLength, 0x20){
            let stringData := mload(add(offset, 0x20))
            sstore(slot, or(stringData, mul(stringLength, 2))) // store stringLength * 2 to ensure the lowest bit is set to 0, which distinguishes short arrays from long arrays.
        }
        if gt(stringLength, 0x1f){
            sstore(slot, add(mul(stringLength, 2), 1)) // store stringLength * 2 + 1 to ensure the lowest bit is set to 1, which distinguishes long arrays from short arrays.
            let stringLocation := getStringLocation(slot)

            // Get the count of storage slots that will occupy the string
            let storageSlotCount
            if eq(mod(stringLength, 0x20), 0) {
                storageSlotCount := div(stringLength, 0x20)
            }
            if iszero(eq(mod(stringLength, 0x20), 0)){
                storageSlotCount := add(div(stringLength, 0x20), 1)
            }

            // Store in storage
            for 
                { let i := 0 }
                lt(i, storageSlotCount)
                { i := add(i, 1) }
            {
                sstore(
                    add(stringLocation, i),
                    mload(add(offset, mul(0x20, add(i, 1))))
                )
            }
        }
    }
  }

  object "Runtime" {
    code {
        // Protection against sending Ether
        if iszero(iszero(callvalue())) {
            revert(0, 0)
        }

        // Dispatcher
        switch selector()
        case 0x8da5cb5b /* owner() */{
            mstore(0, owner())
            return(0, 0x20)
        }
        case 0x06fdde03 /* name() */{
            returnString(name(), nameSlot())
        }

        case 0x95d89b41 /* symbol() */{
            returnString(symbol(), symbolSlot())      
        }

        case 0x313ce567 /* decimals() */{
            returnUint(decimals())
        }

        case 0x18160ddd /* totalSupply() */{
            returnUint(totalSupply())
        }

        case 0x70a08231 /* balanceOf(address) */{
            returnUint(balanceOf(decodeAddress(0)))
        }

        /// @dev Even though it is not stated in the eip-20 specification, the mint function is implemented for convenience
        //
        case 0x40c10f19 /* mint(address,uint256) */{
            // Only owner check
            if iszero(eq(caller(), owner())){
                revert(0,0)
            }

            let to := decodeAddress(0)
            let amount := decodeUint(1)

            // Increase total supply
            sstore(totalSupplySlot(), safeAdd(totalSupply(), amount))

            // Increase receiver balance
            sstore(balancePos(to), safeAdd(balanceOf(to), amount))
        }

        case 0xa9059cbb /* transfer(address,uint256) */{
            let _ownerOf := caller()
            let to := decodeAddress(0)
            let amount := decodeUint(1)

            // Check balance
            if lt(balanceOf(_ownerOf), amount){
                revert(0,0)
            }
              
            // Decrease caller balance
            sstore(balancePos(_ownerOf), sub(balanceOf(_ownerOf), amount))

            // Increase receiver balance
            sstore(balancePos(to), safeAdd(balanceOf(to), amount))

            emitTransfer(_ownerOf, to, amount)

            returnTrue()
        }

        case 0x23b872dd /* transferFrom(address,address,uint256) */{
            let from := decodeAddress(0)
            let to := decodeAddress(1)
            let amount := decodeUint(2)

            // Check allowance
            if lt(allowance(from, caller()), amount){
                revert(0,0)
            }
            // Check balance 
            if lt(balanceOf(from), amount){
                revert(0,0)
            }

            // decrease sender balance
            sstore(balancePos(from), sub(balanceOf(from), amount))

            // increase receiver balance
            sstore(balancePos(to), safeAdd(balanceOf(to), amount))

            //decrease allowance
            sstore(allowancePos(from, caller()), sub(allowance(from, caller()), amount))

            emitTransfer(from, to, amount)

            returnTrue()
        }

        case 0x095ea7b3 /* approve(address,uint256) */{
            let to := decodeAddress(0)
            let amount := decodeUint(1)

            // store the new approval
            sstore(allowancePos(caller(), to), amount)
            
            emitApproval(caller(), to, amount)
            returnTrue()
        }

        case 0xdd62ed3e /* allowance(address,address) */{
            let _owner := decodeAddress(0)
            let _spender := decodeAddress(1)
            returnUint(allowance(_owner, _spender))
        }

        default {
            revert(0,0)
        }

    /** 
     * =============================================
     * GETTERS
     * =============================================
     */ 

        function owner() -> o {
            o := sload(ownerSlot())
        }

        function name() -> n {
            n := sload(nameSlot())
        }

        function symbol() -> s {
            s := sload(symbolSlot())
        }

        function decimals() -> d {
            d := sload(decimalSlot())
        }

        function totalSupply() -> t {
            t := sload(totalSupplySlot())
        }

        function balanceOf(_ownerOf) -> bal {
            bal := sload(balancePos(_ownerOf))
        }

        function allowance(_owner, _spender) -> all {
            all := sload(allowancePos(_owner, _spender))
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
     * STORAGE SLOTS
     * =============================================
     */

        function ownerSlot() -> p { p := 0 }
        function nameSlot() -> p { p := 1 }
        function symbolSlot() -> p { p := 2 }
        function decimalSlot() -> p { p := 3 } 
        function totalSupplySlot() -> p { p := 4 } 
        function balanceSlot() -> p { p := 5 } // mapping(address=>uint256)
        function allowanceSlot() -> p { p := 6 } // mapping(address=>mapping(address=>uint256))

    /** 
     * =============================================
     * HELPERS
     * =============================================
     */

        function selector() -> s {
            s := shr(224, calldataload(0))
        }       

        /// @dev get the slot where is stored the string data
        function getStringLocation(slot) -> l {
            mstore(0, slot)
            l := keccak256(0, 0x20)
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

        function returnString(stringData, slot) {
            let fmp := mload(0x40)
            // if small string
            if iszero(and(stringData, 1)) {
                let stringLength := div(and(stringData, 0xff), 2)
                let stringValue := and(stringData, not(0xff))
                mstore(fmp, 0x20)
                mstore(add(fmp, 0x20), stringLength)
                mstore(add(fmp, 0x40), stringValue)
                return(fmp, add(0x40, stringLength))
            }
            // if large string
            if and(stringData, 1) {
                let stringLength := div(stringData, 2)
                let stringLocation := getStringLocation(slot)
                mstore(fmp, 0x20)
                mstore(add(fmp, 0x20), stringLength)

                // Retrieve the count of occupied storage slots used to store the string.
                let storageSlotCount 
                if eq(mod(stringLength, 0x20), 0) {
                    storageSlotCount := div(stringLength, 0x20)
                }
                if iszero(eq(mod(stringLength, 0x20), 0)){
                    storageSlotCount := add(div(stringLength, 0x20), 1)
                }
                // Store the string in memory
                for { let i := 0 } lt(i, storageSlotCount) { i := add(i, 1) }
                {
                    mstore(
                        add(fmp, mul(0x40, add(i, 1))),
                        sload(add(stringLocation, i))
                    )
                }
                
                return(fmp, add(0x40, stringLength))
            }     
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