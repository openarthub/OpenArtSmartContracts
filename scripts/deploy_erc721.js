// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory('NFTEth')
  const erc721OA = await ERC721OA.deploy(
    '0x0584DA331A3e36e6B587846B3c4150839920Ec9e', // Address of sales contract
    '0x639e34cF634d46f8438e9ebBC11dBBf70aC7ccBA', // Address of auctions contract
  )

  await erc721OA.deployed()
  const erc721OAAddress = erc721OA.address
  console.log(`ERC721OA smart contract deployed at ${erc721OAAddress}`)
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
