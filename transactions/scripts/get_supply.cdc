 /*
 * Copyright (C) Wayports, Inc.
 *
 * SPDX-License-Identifier: (MIT)
 */

// This script reads the total supply field
// of the Lilium smart contract
import Lilium from 0xTOKENADDRESS

pub fun main(): UFix64 {

    let supply = Lilium.totalSupply

    log(supply)

    return supply
}
