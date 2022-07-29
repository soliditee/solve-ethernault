const { network, ethers } = require("hardhat")
const { networkConfig, developmentChains, generateGateKey } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const initAmount = ethers.utils.parseEther("100")

    const player = deployer
    let det, vault, legacy, botAddress
    if (developmentChains.includes(network.name)) {
        const legacyTokenDeployment = await deploy("LegacyToken", {
            from: deployer,
            args: [],
            log: true,
        })
        legacy = await ethers.getContractAt("LegacyToken", legacyTokenDeployment.address, deployer)

        const vaultDeployment = await deploy("CryptoVault", {
            from: deployer,
            args: [deployer],
            log: true,
        })
        vault = await ethers.getContractAt("CryptoVault", vaultDeployment.address, deployer)

        const fortaDeployment = await deploy("Forta", {
            from: deployer,
            args: [],
            log: true,
        })

        const argsDET = [legacy.address, vault.address, fortaDeployment.address, deployer]
        const detDeployment = await deploy("DoubleEntryPoint", {
            from: deployer,
            args: argsDET,
            log: true,
        })
        det = await ethers.getContractAt("DoubleEntryPoint", detDeployment.address, deployer)

        await legacy.mint(vaultDeployment.address, initAmount)
        await vault.setUnderlying(detDeployment.address)
        await legacy.delegateToNewContract(detDeployment.address)

        const botDeployment = await deploy("DETBot", {
            from: player,
            args: [],
            log: true,
        })
        botAddress = botDeployment.address
    } else {
        det = await ethers.getContractAt("DoubleEntryPoint", "0xDC06b6136769AB6662c48D0669dF1065a8240F47", player)
        const vaultAddress = await det.cryptoVault()
        const legacyAddress = await det.delegatedFrom()
        vault = await ethers.getContractAt("CryptoVault", vaultAddress, player)
        legacy = await ethers.getContractAt("LegacyToken", legacyAddress, player)
        botAddress = "0x573F1Dd00887671383c0DD37Df263b2198d09bf5"
    }

    log(`Player = ${player}`)

    const fortaAddress = await det.forta()
    const forta = await ethers.getContractAt("Forta", fortaAddress, player)
    log(`Forta Address = ${forta.address}`)

    const sweptTokensRecipient = await vault.sweptTokensRecipient()
    const bot = await ethers.getContractAt("DETBot", botAddress, player)
    log(`Bot Address = ${bot.address}`)
    const txSetPrevention = await bot.setAddressForPrevention(vault.address, sweptTokensRecipient)
    txSetPrevention.wait(1)

    const detectionBotAddress = await forta.usersDetectionBots(player)

    if (ethers.utils.hexValue(detectionBotAddress).toString() == "0x0") {
        log(`Set detection bot with bot address = ${botAddress}`)
        await forta.setDetectionBot(botAddress)
    }

    const vaultBalanceBefore = await det.balanceOf(vault.address)
    log(`Vault DET Balance Before: ${ethers.utils.formatEther(vaultBalanceBefore)}`)
    try {
        await (await vault.sweepToken(legacy.address)).wait(1)
    } catch (err) {
        log(err)
    }

    const vaultBalanceAfter = await det.balanceOf(vault.address)
    log(`Vault DET Balance After: ${ethers.utils.formatEther(vaultBalanceAfter)}`)
}

module.exports.tags = ["all", "det"]
