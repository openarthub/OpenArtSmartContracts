const { expect, use } = require('chai')
const { deployContract, MockProvider, solidity} = require('ethereum-waffle')
const storageOAArtifact = require('../artifacts/contracts/NFTMarketOA/StorageOA/StorageOA.sol/StorageOA.json')

use(solidity)

describe('CreateItem', () => {
    const [wallet, walletTo] = new MockProvider().getWallets();
    let storageOA

    beforeEach(async () => {
        storageOA = await deployContract(wallet, storageOAArtifact, ['0x0000000000000000000000000000000000000000'])
    })

    it('Should execute only if caller address is in approvals', async () => {
        await expect(storageOA.getDisabledItemsByOwner(wallet.address)).to.be.revertedWith('You are not allowed to execute this method')
    });
    
})
