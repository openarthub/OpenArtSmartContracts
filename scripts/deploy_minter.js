// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
require("dotenv").config()
const storageOAAddress = process.env.CURRENT_STORAGE_ADDRESS
const openArtMarketPlaceAddress = process.env.CURRENT_MAIN_ADDRESS

const main = async () => {
  console.log('Running deployWithEthers script...')

  
  /* *** MinterOA *** */
  const MinterOA = await hre.ethers.getContractFactory('Minter')
  const minterOA = await MinterOA.deploy(
    openArtMarketPlaceAddress, // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await minterOA.deployed()
  const minterOAAddress = minterOA.address
  console.log(`minterOA smart contract deployed at ${minterOAAddress}`)

  console.log('Deployment successful.')


  await minterOA.setApproval('0x1120c2bE89AB1069bBFc36FeeA49E84dBb6D4e6e', true)


  console.log('Approvals set correctly')
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
