object "ERC20" {
  code {
    /* =============================================
    * Storage slots
    * =============================================
    */
    function ownerSlot() -> p { p := 0 }
    function nameSlot() -> p { p := 1 }
    function symbolSlot() -> p { p := 2 }
    function decimalSlot() -> p { p := 3 }    

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
        //let value := mul(nameLength, 2)
        let value := or(0x1, 0x0)
        //let value := nameData
        sstore(nameSlot(), value) // store length * 2 to ensure the lowest bit is set to 0, which distinguishes short arrays from long arrays.
    }
    if gt(nameLength, 0x1f){
        sstore(nameSlot(), add(mul(nameLength, 2), 1)) // store length * 2 + 1 to ensure the lowest bit is set to 1, which distinguishes long arrays from short arrays.
        mstore(fmp, nameSlot())
        let nameDataSlot := keccak256(fmp, 0x20)
        let incrementEnd := 2
        // if eq(mod(nameLength, 0x20), 0) {
        //     incrementEnd := div(nameLength, 0x20)
        // }
        // if iszero(eq(mod(nameLength, 0x20), 0)){
        //     incrementEnd := add(div(nameLength, 0x20), 1)
        // }
        for 
            { let i := 0 }
            lt(i, incrementEnd)
            { i := add(i, 1) }
        {
            sstore(
                add(nameDataSlot, i),
                mload(add(nameOffset, mul(0x20, add(i, 1))))
            )
        }


    // }
    //set symbol
    
    let symbolOffset := mload(0)
    let symbolLength := mload(symbolOffset)
    if lt(symbolLength, 0x20){
        let symbolData := mload(add(symbolOffset, 0x20))
        sstore(symbolSlot(), or(symbolData, mul(symbolLength, 2))) // store length * 2 to ensure the lowest bit is set to 0, which distinguishes short arrays from long arrays.
    }
    if gt(symbolLength, 0x1f){
        sstore(symbolSlot(), add(mul(symbolLength, 2), 1)) // store length * 2 + 1 to ensure the lowest bit is set to 1, which distinguishes long arrays from short arrays.
        mstore(fmp, symbolSlot())
        let symbolDataSlot := keccak256(fmp, 0x20)
        let incrementEnd := 0
        if eq(mod(symbolLength, 0x20), 0) {
            incrementEnd := div(symbolLength, 0x20)
        }
        if iszero(eq(mod(symbolLength, 0x20), 0)){
            incrementEnd := add(div(symbolLength, 0x20), 1)
        }
        for 
            { let i := 0 }
            lt(i, incrementEnd)
            { i := add(i, 1) }
        {
            sstore(
                add(symbolDataSlot, i),
                mload(add(symbolOffset, mul(0x20, add(i, 1))))
            )
        }


    }

    // set decimals
    //
    let decimalsOffset := 0x40 // appears after both string offsets
    //sstore(3, mload(decimalsOffset))
    sstore(decimalSlot(), mload(decimalsOffset))


    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    // 
    code {
        // // nonpayable check
        // if iszero(iszero(callvalue())) {
        //     revert(0, 0)
        // }


        switch selector()
        case 0x06fdde03 /* name()*/{

            let length := sload(nameSlot())

            // Allocate memory for the string
            let fmp := mload(0x40)
            mstore(fmp, 0x20)
            mstore(add(fmp, 0x20), length)
            
            // for {let i := 0} lt(i, length) {add(i, 1)} {
            //     mstore8(add(fmp, 0x40), 0x40)
            // }
            mstore8(add(fmp, 0x40), 0x40)
            mstore8(add(fmp, 0x41), 0x74)

            // Memory pointer to the first element of the string
            return(fmp, 0x42)

            // let value := name()
            // mstore(0x0, value)
            // return(0x0, 0x20)

            
        }
        case 0x313ce567 /* decimals() */{
            let fmp := mload(0x40)
            mstore(fmp, decimals())
            return(fmp, 0x20)
        }




        function selector() -> s {
            s := shr(224, calldataload(0))
        }

        function name() -> n {
            n := sload(0)
        }

        function symbol() -> s {
            s := sload(0x20)
        }

        function decimals() -> d {
            d := sload(3)
        }

        function ownerSlot() -> p { p := 0 }
        function nameSlot() -> p { p := 1 }
        function symbolSlot() -> p { p := 2 }
        function decimalSlot() -> p { p := 3 }   
      
    }
  }
}