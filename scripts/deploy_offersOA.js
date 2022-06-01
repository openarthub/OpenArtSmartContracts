// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
require("dotenv").config()
const storageOAAddress = process.env.CURRENT_STORAGE_ADDRESS
const openArtMarketPlaceAddress = process.env.CURRENT_MAIN_ADDRESS

const main = async () => {
  console.log('Running deployWithEthers script...')

  
  /* *** OffersOA *** */
  const OffersOA = await hre.ethers.getContractFactory('OffersOA')
  const offersOA = await OffersOA.deploy(
    '2', // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await offersOA.deployed()
  const offersOAAddress = offersOA.address
  console.log(`offersOA smart contract deployed at ${offersOAAddress}`)

  console.log('Deployment successful.')

  const storageOA = (await hre.ethers.getContractFactory("StorageOA")).attach(storageOAAddress)
  const openArtOA = (await hre.ethers.getContractFactory("OpenArtMarketPlace")).attach(openArtMarketPlaceAddress)

  await storageOA.setApproval(offersOAAddress, true)

  await offersOA.setApproval(openArtMarketPlaceAddress, true)

  await openArtOA.setOffersAddress(offersOAAddress);

  console.log('Approvals set correctly')
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
