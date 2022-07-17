const { network, ethers } = require("hardhat")
const {
    networkConfig,
    developmentChains,
    generateGateKey,
} = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const gateKeeperDeployment = await deploy("GatekeeperOne", {
        from: deployer,
        args: [],
        log: true,
    })

    const gateKeeperSolverDeployment = await deploy("GatekeeperOneSolver", {
        from: deployer,
        args: [],
        log: true,
    })

    let amountAdditional = 254
    const gateKeeper = await ethers.getContractAt(
        "GatekeeperOne",
        gateKeeperDeployment.address,
        deployer
    )
    const gateKeeperSolver = await ethers.getContractAt(
        "GatekeeperOneSolver",
        gateKeeperSolverDeployment.address,
        deployer
    )
    log(`Deployer=${deployer}`)
    let gateKey = generateGateKey(deployer)
    // let gateKey = generateGateKey("0x5341A9279747B33595e6588B7326c9e0fbF710Eb")
    await gateKeeperSolver.attack(
        gateKeeperDeployment.address,
        gateKey,
        amountAdditional
    )
    // await gateKeeperSolver.testGateThree(gateKey)
}

module.exports.tags = ["all", "gatekeeperone"]
