// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** StorageOA *** */
  const StorageOA = await hre.ethers.getContractFactory('StorageOA')
  const storageOA = await StorageOA.deploy(
    '0x0000000000000000000000000000000000000000', // Backup Address
  )

  await storageOA.deployed()
  const storageOAAddress = storageOA.address
  console.log(`StorageOA smart contract deployed at ${storageOAAddress}`)

  /* *** SalesOA *** */
  const SalesOA = await hre.ethers.getContractFactory('SalesOA')
  const salesOA = await SalesOA.deploy(
    '2', // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await salesOA.deployed()
  const salesOAAddress = salesOA.address
  console.log(`SalesOA smart contract deployed at ${salesOAAddress}`)

  /* *** AuctionsOA *** */
  const AuctionsOA = await hre.ethers.getContractFactory('AuctionsOA')
  const auctionsOA = await AuctionsOA.deploy(
    '2', // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await auctionsOA.deployed()
  const auctionsOAAddress = auctionsOA.address
  console.log(`AuctionsOA smart contract deployed at ${auctionsOAAddress}`)

  /* *** OffersOA *** */
  const OffersOA = await hre.ethers.getContractFactory('OffersOA')
  const offersOA = await OffersOA.deploy(
    '2', // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await offersOA.deployed()
  const offersOAAddress = offersOA.address
  console.log(`OffersOA smart contract deployed at ${offersOAAddress}`)

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

  await storageOA.setApproval(salesOAAddress, true)
  await storageOA.setApproval(offersOAAddress, true)
  await storageOA.setApproval(auctionsOAAddress, true)
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
