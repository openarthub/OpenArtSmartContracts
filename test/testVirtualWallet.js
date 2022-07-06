const { expect, use } = require('chai')
const { deployContract, MockProvider, solidity } = require('ethereum-waffle')
const contractArtifact = require('../artifacts/contracts/VirtualWallet/VirtualWalletOA.sol/VirtualWalletOA.json')
const erc20Artifact = require('../artifacts/contracts/ERC20OA/ERC20OA.sol/ERC20OA.json')

use(solidity)

describe('VirtualWallet Contract', () => {
  const provider = new MockProvider()
  const [wallet, walletTo] = provider.getWallets()
  const wallets = provider.getWallets()
  let virtualWallet
  let erc20

  beforeEach(async () => {
    // create ERC20 contract
    erc20 = await deployContract(
      wallet,
      erc20Artifact,
      [
        'ganacheToken', // Name token
        'gnc', // Symbol token
        wallet.address, // Address Admin
        '0x4e34EeC85C800Fc61829b1b50Edb0a45f57BB632', //Address Marketing
        '0x33f99cC965Ea46A44eAc7d4fDAff91429Ee4E43a', // Address Development
        '0x31c6683a2f80B17c9576a39554505CBdCb80501e', // Helping address,
        '0x1EF008Fe5bDEE78b1C2Aafaf60631f40e84B3374', // Rewards Address
      ]
    )
    await erc20.deployed()
  
    // Create virtual wallet instance
    virtualWallet = await deployContract(wallet, contractArtifact, [erc20.address, wallet.address])
    await virtualWallet.deployed()

    // set Excempt fees
    await erc20.setExemptFeesIn(virtualWallet.address, true)
    await erc20.setExemptFeesOut(virtualWallet.address, true)

  })

  describe('TransferOART', () => {
    it('Should execute only if caller address is in approvals', async () => {
      const virtualWalletUser = virtualWallet.connect(walletTo)
      await expect(
        virtualWalletUser.transferOART(walletTo.address, wallet.address, 300)
      ).to.be.revertedWith('You are not allowed to execute this method')
    })

    it('Should not execute if user does not have enough balance', async () => {
      await expect(
        virtualWallet.transferOART(walletTo.address, wallet.address, 300)
      ).to.be.revertedWith('Transfer amount exceeds balance.')
    })

    it('Should decrease balance when user makes transaction', async () => {
      await erc20.approve(virtualWallet.address, 100)
      await virtualWallet.fundOART(100)
      await virtualWallet.transferOART(wallet.address, walletTo.address, 98)
      const response = await virtualWallet.getBalances(wallet.address)
      expect(
        response.oartBalance.toString()
      ).to.be.equal('2')
    })

  })

  describe('Transfer', () => {
    it('Should execute only if caller address is in approvals', async () => {
      const virtualWalletUser = virtualWallet.connect(walletTo)
      await expect(
        virtualWalletUser.transfer(walletTo.address, wallet.address, 300)
      ).to.be.revertedWith('You are not allowed to execute this method')
    })

    it('Should not execute if user does not have enough balance', async () => {
      await expect(
        virtualWallet.transfer(walletTo.address, wallet.address, 300)
      ).to.be.revertedWith('Transfer amount exceeds balance.')
    })

    it('Should decrease balance when user makes transaction', async () => {
      await virtualWallet.fundAccount({value: 1000})
      await virtualWallet.transfer(wallet.address, walletTo.address, 999)
      const response = await virtualWallet.getBalances(wallet.address)
      expect(
        response.ethBalance.toString()
      ).to.be.equal('1')
    })

  })

  describe('FundOART', () => {

    beforeEach(async () => { await erc20.approve(virtualWallet.address, 100) })

    it('Should Increase contract balance', async () => {
      await expect(
        () => virtualWallet.fundOART(100)
      ).to.changeTokenBalances(
        erc20,
        [wallet, virtualWallet],
        [-100, 100]
      )
    })

    it('Should modify the balance user Virtual Wallet balance', async () => {
      await virtualWallet.fundOART(100)
      const response = await virtualWallet.getBalances(wallet.address)
      expect(
        response.oartBalance.toString()
      ).to.be.equal('100')
    })

  })

  describe('FundAccount', () => {

    it('Should increase eth contract balance', async () => {
      await expect(
        () => virtualWallet.fundAccount({ value: 15 })
      ).to.changeEtherBalances(
        [wallet, virtualWallet],
        [-15, 15]
      )
    })

    it('Should modify the balance user Virtual Wallet balance', async () => {
      await virtualWallet.fundAccount({ value: 12 })
      const response = await virtualWallet.getBalances(wallet.address)
      expect(
        response.ethBalance.toString()
      ).to.be.equal('12')
    })
  })

  describe('Withdraw OARTs', () => {

    beforeEach(async () => {
      await erc20.approve(virtualWallet.address, 100)
      await virtualWallet.fundOART(100)
    })

    it('Should increase oart user balance', async () => {
      await expect(
        () => virtualWallet.withdrawOART(15)
      ).to.changeTokenBalances(
        erc20,
        [wallet, virtualWallet],
        [15, -15]
      )
    })

    it('Should modify virtual oart balance in user\'s Virtual Wallet', async () => {
      await virtualWallet.withdrawOART(10)
      const response = await virtualWallet.getBalances(wallet.address)
      expect(
        response.oartBalance.toString()
      ).to.be.equal('90')
    })

    it('Should revert an error for exceeds balance', async () => {
      await expect(
        virtualWallet.withdrawOART(1000)
      ).to.be.revertedWith('Not enough balance')
    })

  })

  describe('Withdraw', () => {
    beforeEach(async () => { await virtualWallet.fundAccount({ value: 100 }) })

    it('Should increase eth user balance', async () => {
      await expect(
        () => virtualWallet.withdraw(15)
      ).to.changeEtherBalances(
        [wallet, virtualWallet],
        [15, -15]
      )
    })

    it('Should modify virtual eth balance in user\'s Virtual Wallet', async () => {
      await virtualWallet.withdraw(10)
      const response = await virtualWallet.getBalances(wallet.address)
      expect(
        response.ethBalance.toString()
      ).to.be.equal('90')
    })

    it('Should revert an error for exceeds balance', async () => {
      await expect(
        virtualWallet.withdrawOART(200)
      ).to.be.revertedWith('Not enough balance')
    })

  })
})