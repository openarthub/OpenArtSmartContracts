// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory("ERC721Royalties")
  const erc721OA = await ERC721OA.deploy("RoyaltiesCollection", "RC");

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
