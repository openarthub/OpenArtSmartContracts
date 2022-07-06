// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
require('dotenv').config()

const storageOAAddress = process.env.CURRENT_STORAGE_ADDRESS
const salesOAAddress = process.env.CURRENT_SALES_ADDRESS
const auctionsOAAddress = process.env.CURRENT_AUCTIONS_ADDRESS
const offersOAAddress = process.env.CURRENT_OFFERS_ADDRESS


const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** OpenArtMarketPlace *** */
  const OpenArtMarketPlace = await hre.ethers.getContractFactory('OpenArtMarketPlace')
  const openArtMarketPlace = await OpenArtMarketPlace.deploy(
    storageOAAddress, // Address of StorageOA contract
    salesOAAddress, // Address of SalesOA contract
    auctionsOAAddress, // Address of AuctionsOA contract
    offersOAAddress, // Address of OffersOA contract
  )

  await openArtMarketPlace.deployed()
  const openArtMarketPlaceAddress = openArtMarketPlace.address
  console.log(`OpenArtMarketPlace smart contract deployed at ${openArtMarketPlaceAddress}`)

  console.log('Deployment successful.')

  const storageOA = (await hre.ethers.getContractFactory("StorageOA")).attach(storageOAAddress)
  const salesOA = (await hre.ethers.getContractFactory("SalesOA")).attach(salesOAAddress)
  const auctionsOA = (await hre.ethers.getContractFactory("AuctionsOA")).attach(auctionsOAAddress)
  const offersOA = (await hre.ethers.getContractFactory("OffersOA")).attach(offersOAAddress)


  await storageOA.setApproval(openArtMarketPlaceAddress, true)

  await salesOA.setApproval(openArtMarketPlaceAddress, true)
  await auctionsOA.setApproval(openArtMarketPlaceAddress, true)
  await offersOA.setApproval(openArtMarketPlaceAddress, true)

  console.log('Approvals set correctly')
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
