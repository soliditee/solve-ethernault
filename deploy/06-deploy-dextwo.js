const { network, ethers, getUnnamedAccounts } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let target
    let t1, t2

    async function printBalance(tokenContractAddress, holderAddress, holderName) {
        const erc20Contract = await ethers.getContractAt("SwappableTokenTwo", tokenContractAddress, deployer)
        const balanceAmount = await erc20Contract.balanceOf(holderAddress)
        console.log(`${holderName} Balance = ${balanceAmount}`)
    }

    const approveAmount = "300"
    if (developmentChains.includes(network.name)) {
        log("Localhost: Deploying target contract...")
        const targetDeployment = await deploy("DexTwo", {
            from: deployer,
            args: [],
            log: true,
        })

        target = await ethers.getContractAt("DexTwo", targetDeployment.address, deployer)

        // Deploy token1 and token2
        const initialSupply = "110"
        const argsToken1 = [target.address, "Token1", "T1", initialSupply]
        const argsToken2 = [target.address, "Token2", "T2", initialSupply]
        const token1Deployment = await deploy("SwappableTokenTwo", {
            from: deployer,
            args: argsToken1,
            log: true,
        })
        const token2Deployment = await deploy("SwappableTokenTwo", {
            from: deployer,
            args: argsToken2,
            log: true,
        })

        t1 = token1Deployment.address
        t2 = token2Deployment.address
        // Make sure Dex balance is 100 and deployer balance is 10
        await target.setTokens(t1, t2)
        await target.approve(target.address, approveAmount)
        await target.add_liquidity(token1Deployment.address, "100")
        await target.add_liquidity(token2Deployment.address, "100")
    } else {
        // Get the contract address in Rinkeby
        target = await ethers.getContractAt("DexTwo", "0x7b72b6801793403722cbD34e64972CF7C411Eb22", deployer)
        t1 = await target.token1()
        t2 = await target.token2()
    }

    await printBalance(t1, target.address, "Dex T1")
    await printBalance(t2, target.address, "Dex T2")
    await printBalance(t1, deployer, "Player T1")
    await printBalance(t2, deployer, "Player T2")

    // Deploy a Trash token to swap with t1 and t2
    const argsToken3 = [target.address, "Token3", "T3", "400"]
    const token3Deployment = await deploy("SwappableTokenTwo", {
        from: deployer,
        args: argsToken3,
        log: true,
    })

    const t3 = token3Deployment.address
    const t3Contract = await ethers.getContractAt("SwappableTokenTwo", t3, deployer)
    await t3Contract.approveNew(deployer, target.address, approveAmount)
    await t3Contract.approveNew(deployer, deployer, approveAmount)
    await t3Contract.transferFrom(deployer, target.address, "100")
    await printBalance(t3, target.address, "Dex T3")
    await printBalance(t3, deployer, "Player T3")

    // Swap 100 T3 to get 100 T1
    await target.swap(t3, t1, "100")
    await printBalance(t3, target.address, "Dex T3 After T1 Swap")
    await printBalance(t1, deployer, "Player T1 After T1 Swap")

    // // Swap 200 T3 to get 100 T2
    await target.swap(t3, t2, "200")
    await printBalance(t3, target.address, "Dex T3 After T2 Swap")
    await printBalance(t2, deployer, "Player T2 After T2 Swap")

    // Confirm final result
    await printBalance(t1, target.address, "Dex T1 Final")
    await printBalance(t2, target.address, "Dex T2 Final")
}

module.exports.tags = ["all", "dextwo"]
