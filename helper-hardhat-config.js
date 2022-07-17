const { ethers } = require("hardhat")

const networkConfig = {
    4: {
        name: "rinkeby",
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
    },
}

const developmentChains = ["hardhat", "localhost"]
const MOCK_DECIMALS = 8
const MOCK_ANSWER = 1200 * 10 ** MOCK_DECIMALS

/**
 * Generate the gate key for GatekeeperOne challenge
 *
 * @param deployerAddress - Address string
 */
function generateGateKey(deployerAddress) {
    let gateKeyArray = ethers.utils.arrayify(deployerAddress)
    gateKeyArray = gateKeyArray.slice(12, 20)
    // Delete the 4th and 5th byte so that uint32 == uint16
    gateKeyArray[4] = 0
    gateKeyArray[5] = 0
    let uint16Key = parseInt(
        // @ts-ignore
        Number(ethers.utils.hexlify(gateKeyArray.slice(6, 8)))
    )
    let uint32Key = parseInt(
        // @ts-ignore
        Number(ethers.utils.hexlify(gateKeyArray.slice(4, 8)))
    )
    console.log(`--- uint16Key = ${uint16Key}`)
    console.log(`--- uint32Key = ${uint32Key}`)
    let hexValueToReturn = ethers.utils.hexlify(gateKeyArray)
    console.log(gateKeyArray)
    console.log(`--- hexValueToReturn = ${hexValueToReturn}`)
    return hexValueToReturn
}

module.exports = {
    networkConfig,
    developmentChains,
    MOCK_DECIMALS,
    MOCK_ANSWER,
    generateGateKey,
}
