const { network, ethers, getUnnamedAccounts } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let target
    if (developmentChains.includes(network.name)) {
        log("Localhost: Deploying target contract...")
        const targetDeployment = await deploy("Shop", {
            from: deployer,
            args: [],
            log: true,
        })

        target = await ethers.getContractAt("Shop", targetDeployment.address, deployer)
    } else {
        // Get the contract address in Rinkeby
        target = await ethers.getContractAt("Shop", "0xbbFADf3DA2a294C87b95b4dEC349A7526e4006Ae", deployer)
    }

    const solverDeployment = await deploy("ShopSolver", {
        from: deployer,
        args: [target.address],
        log: true,
    })

    const solver = await ethers.getContractAt("ShopSolver", solverDeployment.address, deployer)

    const priceBefore = await target.price()
    log(`Price Before: ${priceBefore}`)
    await solver.attack()
    const priceAfter = await target.price()
    log(`Price After: ${priceAfter}`)
}

module.exports.tags = ["all", "shop"]
