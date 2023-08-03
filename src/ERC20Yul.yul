object "ERC20" {
  code {
    //let value := add(dataoffset("Runtime"), datasize("Runtime"))
    let value := datasize("ERC20")
    //let value := dataoffset("ERC20")
    sstore(0, value)


    //copy into memory arguments
    codecopy(0, datasize("ERC20"), codesize())
    let fmp := codesize()

    // handle decimals
        //
        let decimalsOffset := 0x40 // appears after both string offsets
        sstore(3, mload(decimalsOffset))


    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    // 
    code {

        switch selector()
        case 0x06fdde03 /* name()*/{
            // let fmp := mload(0x40)
            // let value := name()
            // // mstore8(fmp, shr(32, value))
            // // mstore8(add(fmp, 0x20), shr(24, value))
            // // mstore8(fmp, name())
            // // mstore8(fmp, name())
            // // mstore8(fmp, name())
            // mstore(fmp, 0x01)
            // mstore(add(fmp, 0x20), 0x74)

            // return(fmp, 0x40)
            // Length of the string (in bytes)
            let length := 2

            // Allocate memory for the string
            let fmp := mload(0x40)
            mstore(fmp, 0x20)
            mstore(add(fmp, 0x20), length)
            mstore8(add(fmp, 0x40), 0x74)
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
      
    }
  }
}