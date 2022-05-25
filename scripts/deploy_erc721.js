// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory('NFTEth')
  const erc721OA = await ERC721OA.deploy(
    '0x8486770dF0a8FFA81d9380e0f2D9a4bbc554e8C0', // Address of market contract
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
