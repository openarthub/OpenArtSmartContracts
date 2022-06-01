// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
require('dotenv').config()

const storageOAAddress = process.env.CURRENT_STORAGE_ADDRESS
const openArtMarketPlaceAddress = process.env.CURRENT_MAIN_ADDRESS

const main = async () => {
  console.log('Running deployWithEthers script...')

  
  /* *** AuctionsOA *** */
  const AuctionsOA = await hre.ethers.getContractFactory('AuctionsOA')
  const auctionsOA = await AuctionsOA.deploy(
    '2', // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await auctionsOA.deployed()
  const auctionsOAAddress = auctionsOA.address
  console.log(`AuctionsOA smart contract deployed at ${auctionsOAAddress}`)

  console.log('Deployment successful.')

  const storageOA = (await hre.ethers.getContractFactory("StorageOA")).attach(storageOAAddress)

  await storageOA.setApproval(auctionsOAAddress, true)

  await auctionsOA.setApproval(openArtMarketPlaceAddress, true)

  console.log('Approvals set correctly')
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
