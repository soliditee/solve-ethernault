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

    const gateKeeperDeployment = await deploy("GatekeeperTwo", {
        from: deployer,
        args: [],
        log: true,
    })

    const gateKeeperSolverDeployment = await deploy("GatekeeperTwoSolver", {
        from: deployer,
        args: [gateKeeperDeployment.address],
        log: true,
    })
}

module.exports.tags = ["all", "gatekeepertwo"]
