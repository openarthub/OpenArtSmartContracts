// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory('NFTEth')
  const erc721OA = await ERC721OA.deploy(
    '0x0e486ACF8B867AA79361E9346C4918cf7B5cd7CD', // Address of sales contract
    '0xE8b0f5B2036FaaCe506f20bb9829F88aE60D2d22', // Address of auctions contract
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
