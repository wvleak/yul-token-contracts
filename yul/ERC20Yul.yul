object "ERC20" {
  code {
    /** 
     * =============================================
     * HELPERS
     * =============================================
     */
    function ownerSlot() -> p { p := 0 }
    function nameSlot() -> p { p := 1 }
    function symbolSlot() -> p { p := 2 }
    function decimalSlot() -> p { p := 3 }    
    function getStringLocation(slot) -> l {
        mstore(0, slot)
        l := keccak256(0, 0x20)
    }  

    // copy arguments into memory
    codecopy(0, datasize("ERC20"), sub(codesize(), datasize("ERC20"))) // encoded after the main code 
    let fmp := codesize()

    //set owner
    sstore(ownerSlot(), caller())

    
    //handle strings like in solidity
    //
    //set name
    
    let nameOffset := mload(0)
    let nameLength := mload(nameOffset)
    if lt(nameLength, 0x20){
        let nameData := mload(add(nameOffset, 0x20))
        sstore(nameSlot(), or(nameData, mul(nameLength, 2))) // store length * 2 to ensure the lowest bit is set to 0, which distinguishes short arrays from long arrays.
    }
    if gt(nameLength, 0x1f){
        sstore(nameSlot(), add(mul(nameLength, 2), 1)) // store length * 2 + 1 to ensure the lowest bit is set to 1, which distinguishes long arrays from short arrays.
        let nameLocation := getStringLocation(nameSlot())

        // Get the count of storage slots that will occupy the name.
        let incrementEnd 
        if eq(mod(nameLength, 0x20), 0) {
            incrementEnd := div(nameLength, 0x20)
        }
        if iszero(eq(mod(nameLength, 0x20), 0)){
            incrementEnd := add(div(nameLength, 0x20), 1)
        }

        // Store in storage
        for { let i := 0 } lt(i, incrementEnd) { i := add(i, 1) }
        {
            sstore(
                add(nameLocation, i),
                mload(add(nameOffset, mul(0x20, add(i, 1))))
            )
        }


     }
    //set symbol
    
    let symbolOffset := mload(0x20)
    let symbolLength := mload(symbolOffset)
    if lt(symbolLength, 0x20){
        let symbolData := mload(add(symbolOffset, 0x20))
        sstore(symbolSlot(), or(symbolData, mul(symbolLength, 2))) // store length * 2 to ensure the lowest bit is set to 0, which distinguishes short arrays from long arrays.
    }
    if gt(symbolLength, 0x1f){
        sstore(symbolSlot(), add(mul(symbolLength, 2), 1)) // store length * 2 + 1 to ensure the lowest bit is set to 1, which distinguishes long arrays from short arrays.
        let symbolLocation := getStringLocation(symbolSlot())

        // Get the count of storage slots that will occupy the symbol.
        let storageSlotCount
        if eq(mod(symbolLength, 0x20), 0) {
            storageSlotCount := div(symbolLength, 0x20)
        }
        if iszero(eq(mod(symbolLength, 0x20), 0)){
            storageSlotCount := add(div(symbolLength, 0x20), 1)
        }

        // Store in storage
        for 
            { let i := 0 }
            lt(i, storageSlotCount)
            { i := add(i, 1) }
        {
            sstore(
                add(symbolLocation, i),
                mload(add(symbolOffset, mul(0x20, add(i, 1))))
            )
        }


    }

    // set decimals
    //
    let decimalsOffset := 0x40 // appears after both string offsets
    sstore(decimalSlot(), mload(decimalsOffset))


    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    // 
    code {
        // nonpayable check
        if iszero(iszero(callvalue())) {
            revert(0, 0)
        }

        switch selector()
        case 0x8da5cb5b /* owner() */{
            mstore(0, owner())
            return(0, 0x20)
        }
        case 0x06fdde03 /* name() */{
             
            let fmp := mload(0x40)

            let nameData := name()

            // if small string
            if iszero(and(nameData, 1)) {
                let nameLength := and(nameData, 0xff)
                let nameValue := and(nameData, not(0xff))
                mstore(fmp, 0x20)
                mstore(add(fmp, 0x20), nameLength)
                mstore(add(fmp, 0x40), nameValue)
                return(fmp, 0x60)
            }
            // if large string
            if and(nameData, 1) {
                let nameLength := nameData
                let nameLocation := getStringLocation(nameSlot())
                mstore(fmp, 0x20)
                mstore(add(fmp, 0x20), nameLength)

                // Retrieve the count of occupied storage slots used to store the name.
                let storageSlotCount 
                if eq(mod(nameLength, 0x20), 0) {
                    storageSlotCount := div(nameLength, 0x20)
                }
                if iszero(eq(mod(nameLength, 0x20), 0)){
                    storageSlotCount := add(div(nameLength, 0x20), 1)
                }
                // Store the name in memory
                for { let i := 0 } lt(i, storageSlotCount) { i := add(i, 1) }
                {
                    mstore(
                        add(fmp, mul(0x40, add(i, 1))),
                        sload(add(nameLocation, i))
                    )
                }

                return(fmp, add(0x40, nameLength))
                
            }      
        }
        case 0x95d89b41 /* symbol() */{

            let fmp := mload(0x40)

            let symbolData := symbol()

            // if small string
            if iszero(and(symbolData, 1)) {
                let symbolLength := and(symbolData, 0xff)
                let symbolValue := and(symbolData, not(0xff))
                mstore(fmp, 0x20)
                mstore(add(fmp, 0x20), symbolLength)
                mstore(add(fmp, 0x40), symbolValue)
                return(fmp, 0x60)
            }
            // if large string
            if and(symbolData, 1) {
                let symbolLength := symbolData
                let symbolLocation := getStringLocation(symbolSlot())
                mstore(fmp, 0x20)
                mstore(add(fmp, 0x20), symbolLength)

                // Retrieve the count of occupied storage slots used to store the symbol.
                let storageSlotCount 
                if eq(mod(symbolLength, 0x20), 0) {
                    storageSlotCount := div(symbolLength, 0x20)
                }
                if iszero(eq(mod(symbolLength, 0x20), 0)){
                    storageSlotCount := add(div(symbolLength, 0x20), 1)
                }
                // Store the symbol in memory
                for { let i := 0 } lt(i, storageSlotCount) { i := add(i, 1) }
                {
                    mstore(
                        add(fmp, mul(0x40, add(i, 1))),
                        sload(add(symbolLocation, i))
                    )
                }
                
                return(fmp, add(0x40, symbolLength))
            }         
        }

        case 0x313ce567 /* decimals() */{
            returnUint(decimals())
        }

        case 0x18160ddd /* totalSupply() */{
            returnUint(totalSupply())
        }

        case 0x70a08231 /* balanceOf(address) */{
            let _ownerOf := calldataload(0x04)
            returnUint(balanceOf(_ownerOf))
        }

        case 0xa9059cbb /* transfer(address,uint256) */{
            let _ownerOf := caller()
            let to := calldataload(0x04)
            let amount := calldataload(0x24)
            //Check balance

            if lt(balanceOf(_ownerOf), amount){
                revert(0,0)
            }
              

            // decrease caller balance
            sstore(balancePos(_ownerOf), sub(balanceOf(_ownerOf), amount))

            // increase receiver balance
            sstore(balancePos(to), safeAdd(balanceOf(to), amount))

            mstore(0, 1)
            return(0, 0x20)
        }

        case 0x40c10f19 /* mint(address,uint256) */{
            // Only owner check
            if iszero(eq(caller(), owner())){
                revert(0,0)
            }

            let to := calldataload(0x04)
            let amount := calldataload(0x24)

            // increase receiver balance
            sstore(balancePos(to), safeAdd(balanceOf(to), amount))
            //sstore(balancePos(to), amount)
            // let value := calldataload(0x24)
            // mstore(0, value)
            // return(0, 0x20)


        }

        case 0xdd62ed3e /* allowance(address,address) */{
            let _owner := calldataload(0x04)
            let _spender := calldataload(0x24)
            returnUint(allowance(_owner, _spender))
        }

        case 0x095ea7b3 /* approve(address,uint256) */{
            let to := calldataload(0x04)
            let amount := calldataload(0x24)
            sstore(allowancePos(caller(), to), amount)

            // return true
            mstore(0, 1)
            return(0, 0x20)
        }

        case 0x23b872dd /* transferFrom(address,address,uint256) */{
            let from := calldataload(0x04)
            let to := calldataload(0x24)
            let amount := calldataload(0x44)

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

            mstore(0, 1)
            return(0, 0x20)


        }

        default {
            revert(0,0)
        }






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

        function getStringLocation(slot) -> l {
            mstore(0, slot)
            l := keccak256(0, 0x20)
        } 

        function balancePos(value) -> p {
            mstore(0, value)
            mstore(0x20, balanceSlot())
            p := keccak256(0, 0x40)
        }

        function allowancePos(_owner, _spender) -> pos {
            // nested mapping
            mstore(0, _owner)
            mstore(0x20, allowanceSlot())
            let p := keccak256(0, 0x40)
            mstore(0, _spender)
            mstore(0x20, p)
            pos := keccak256(0, 0x40)

        }

        function returnUint(value) {
            let fmp := mload(0x40)
            mstore(fmp, value)
            return(fmp, 0x20)
        }

        function safeAdd(a, b) -> value {
            value := add(a, b)
            if or(lt(value, a), lt(value, b)){
                revert(0,0)
            }
        }
      
    }
  }
}