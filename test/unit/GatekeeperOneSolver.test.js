// @ts-nocheck

const { assert, expect } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

describe("GatekeeperOneSolver", function () {
    let gateKeeper
    let gateKeeperSolver
    let deployer
    let gateKey = "0x5b380000701c5685"
    let amountAdditional = 254

    beforeEach(async function () {
        await deployments.fixture("gatekeeperone")
        deployer = (await getNamedAccounts()).deployer
        gateKeeper = await ethers.getContract("GatekeeperOne", deployer)
        gateKeeperSolver = await ethers.getContract(
            "GatekeeperOneSolver",
            deployer
        )
    })

    describe("gateTwo", function () {
        it("Find out the gasleft() amount", async function () {
            // for (i = 0; i < 400; i++) {
            //     await expect(
            //         gateKeeperSolver.attack(gateKeeper.address, gateKey, i)
            //     ).to.be.revertedWith("Incorrect gasleft()")
            // }
            await gateKeeperSolver.attack(
                gateKeeper.address,
                gateKey,
                amountAdditional
            )
        })
    })
})
