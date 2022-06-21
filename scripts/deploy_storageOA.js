// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** StorageOA *** */
  const StorageOA = await hre.ethers.getContractFactory('StorageOA')
  const storageOA = await StorageOA.deploy(
    '0xF38D7a67f805c5FcB008B34C8205C364410894C8', // Backup Address
  )

  await storageOA.deployed()
  const storageOAAddress = storageOA.address
  console.log(`StorageOA smart contract deployed at ${storageOAAddress}`)

  /* *** SalesOA *** */

  const salesOAAddress = '0x0e486ACF8B867AA79361E9346C4918cf7B5cd7CD'
  const salesOA = (await hre.ethers.getContractFactory("SalesOA")).attach(salesOAAddress)

  /* *** AuctionsOA *** */

  const auctionsOAAddress = '0xE8b0f5B2036FaaCe506f20bb9829F88aE60D2d22'
  const auctionsOA = (await hre.ethers.getContractFactory("AuctionsOA")).attach(auctionsOAAddress)

  /* *** OffersOA *** */

  const offersOAAddress = '0xF0A293B669BA763b1a1D3531A3C9da461eFC9190'
  const offersOA = (await hre.ethers.getContractFactory("OffersOA")).attach(offersOAAddress)

  /* *** OpenArtMarketPlace *** */

  const openArtMarketPlaceAddress = '0xC010342E24c59eA97bCb4A3489F5207F9DA979F9'
  const openArt = (await hre.ethers.getContractFactory("OpenArtMarketPlace")).attach(openArtMarketPlaceAddress)

  console.log('Deployment successful.')

  await storageOA.setApproval(salesOAAddress, true)
  await storageOA.setApproval(offersOAAddress, true)
  await storageOA.setApproval(auctionsOAAddress, true)
  await storageOA.setApproval(openArtMarketPlaceAddress, true)

  await salesOA.setStorageAddress(storageOAAddress)
  await auctionsOA.setStorageAddress(storageOAAddress)
  await offersOA.setStorageAddress(storageOAAddress)
  await openArt.setStorageAddress(storageOAAddress)

  console.log('Approvals set correctly')
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
