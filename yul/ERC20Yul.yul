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
            let fmp := mload(0x40)
            mstore(fmp, decimals())
            return(fmp, 0x20)
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
      
    }
  }
}