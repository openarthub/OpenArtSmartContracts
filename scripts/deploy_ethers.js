// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
(async () => {
  try {
    console.log('Running deployWithEthers script...')
    const ERC20OA = await hre.ethers.getContractFactory('ERC20OA')
    const erc20OA = await ERC20OA.deploy(
      'test', // Name token
      'tst', // Symbol token
      '0xAE8C6d624bC59F1B7CeA1F6d17255A995930a31F', // Address Admin
      '0x794Fed8D9bEe97a7e352e4C308Cec5632b741104', //Address Marketing
      '0x8A7e80fDF8c8c6f236d6e230F99633869AB8C4de', // Address Development
      '0xbef2576102146b7BcAb08DD39c195aeD21372998', // Helping address,
      '0x1F34D46f8467429a7a4fdFb37D0Cb825f3aeD48F', // Rewards Address
    )

    await erc20OA.deployed()
    
    const erc20OAAddress = erc20OA.address
    console.log(`ERC20OA smart contract deployed at ${erc20OAAddress}`)

    const PresaleOA = await hre.ethers.getContractFactory('PreSale')
    const presale = await PresaleOA.deploy(
      erc20OAAddress, // Address of token to hold
      '1660923000' // End time in epoch time
    )

    await presale.deployed()

    const presaleAddress = presale.address
    console.log(`Presale smart contract deployed at ${presaleAddress}`)

    console.log('Deployment successful.')
  } catch (e) {
    console.log(e.message)
  }
})()