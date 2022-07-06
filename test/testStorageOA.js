const { expect, use } = require('chai')
const { deployContract, MockProvider, solidity} = require('ethereum-waffle')
const storageOAArtifact = require('../artifacts/contracts/NFTMarketOA/StorageOA/StorageOA.sol/StorageOA.json')
const erc721OAArtifact = require('../artifacts/contracts/ERC721OA/ERC721EthereumOA.sol/NFTEth.json')
const marketOAArtifact = require('../artifacts/contracts/NFTMarketOA/NFTMarketOA/NFTMarketOA.sol/NFTMarketOA.json')

use(solidity)

describe('Storage Contract', () => {

  const provider = new MockProvider()
  const [wallet, walletTo] = provider.getWallets();
  const wallets = provider.getWallets()
  let marketOA
  let storageOA
  let erc721OA

  beforeEach(async () => {
    // Create instance of previous version of marketplace contract
    marketOA = await deployContract(
      wallet,
      marketOAArtifact,
      [2, '0x0000000000000000000000000000000000000000']
    )
    await marketOA.deployed()
    
    // Create instance of ERC721
    erc721OA = await deployContract(
      wallet,
      erc721OAArtifact,
      [marketOA.address]
    )
    
    await erc721OA.deployed()
    
    // Create connection from second user's wallet
    const erc721OAUser = erc721OA.connect(wallets[0])
    
    // Mint NFT
    let id = await erc721OAUser.createToken('https//token.com')
    id = await id.wait()
    id = id.events[0]
    id = id.args[2].toNumber()


    const marketOAUser = marketOA.connect(wallets[0])

    await marketOAUser.createMarketItem(
      erc721OA.address,
      id,
      true
    )

    id = await erc721OAUser.createToken('https//token.com')
    id = await id.wait()
    id = id.events[0]
    id = id.args[2].toNumber()

    await marketOAUser.createMarketItem(
      erc721OA.address,
      id,
      true
    )

    id = await erc721OAUser.createToken('https//token.com')
    id = await id.wait()
    id = id.events[0]
    id = id.args[2].toNumber()

    await marketOAUser.createMarketItem(
      erc721OA.address,
      id,
      true
    )

    // Create instance of current version of contract
    storageOA = await deployContract(
      wallets[0],
      storageOAArtifact,
      [marketOA.address]
    )
  })

  describe('CreateItem', () => {
    const [wallet] = new MockProvider().getWallets();

    it('Should execute only if caller address is in approvals', async () => {
      await expect(
        storageOA.getDisabledItemsByOwner(wallet.address)
      ).to.be.revertedWith('You are not allowed to execute this method')
    });
  })
  
  describe('Constructor', () => {
    it('Should return the same items than the previous contract', async () => {
      const items = await marketOA.fetchMarketItems()
      expect((await storageOA.getItems()).length).to.be.equals(items.length)
    })
  })
});

