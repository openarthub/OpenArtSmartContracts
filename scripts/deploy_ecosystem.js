// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
require('dotenv').config()

const adminAddress = process.env.ADMIN_ADDRESS

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

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory('NFTEth')
  const erc721OA = await ERC721OA.deploy(
    salesOAAddress, // Address of sales contract
    auctionsOAAddress, // Address of auctions contract
  )
  
  await erc721OA.deployed()
  const erc721OAAddress = erc721OA.address
  console.log(`ERC721OA smart contract deployed at ${erc721OAAddress}`)

  
  const ERC20OA = await hre.ethers.getContractFactory('ERC20OA')
  const erc20OA = await ERC20OA.deploy(
    'HardHatToken', // Name token
    'HHT', // Symbol token
    adminAddress, // Address Admin
    '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', //Address Marketing
    '0x70997970C51812dc3A010C7d01b50e0d17dc79C8', // Address Development
    '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', // Helping address,
    '0x90F79bf6EB2c4f870365E785982E1f101E93b906', // Rewards Address
  )

  await erc20OA.deployed()

  const erc20OAAddress = erc20OA.address
  console.log(`ERC20OA smart contract deployed at ${erc20OAAddress}`)


    /* *** MinterOA *** */
    const MinterOA = await hre.ethers.getContractFactory('Minter')
    const minterOA = await MinterOA.deploy(
      "0xdD2FD4581271e230360230F9337D5c0430Bf44C0", // Listing price in percent (0 - 100)
      storageOAAddress, // Address of StorageOA contract
    )
  
    await minterOA.deployed()
    const minterOAAddress = minterOA.address
    console.log(`minterOA smart contract deployed at ${minterOAAddress}`)
  
    console.log('Deployment successful.')
  
  
    await minterOA.setApproval('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', true)

  console.log('Deployment successful.')

  await storageOA.setApproval(salesOAAddress, true)
  await storageOA.setApproval(offersOAAddress, true)
  await storageOA.setApproval(auctionsOAAddress, true)
  await storageOA.setApproval(openArtMarketPlaceAddress, true)
  await storageOA.setTrustedAddress(minterOAAddress)

  await salesOA.setApproval(openArtMarketPlaceAddress, true)
  await auctionsOA.setApproval(openArtMarketPlaceAddress, true)
  await offersOA.setApproval(openArtMarketPlaceAddress, true)

  console.log('Approvals set correctly')

  await erc20OA.setExemptFeesIn(offersOAAddress, true)
  await erc20OA.setExemptFeesOut(offersOAAddress, true)

  await erc20OA.setExemptFeesIn(salesOAAddress, true)
  await erc20OA.setExemptFeesOut(salesOAAddress, true)

  await erc20OA.setExemptFeesIn(auctionsOAAddress, true)
  await erc20OA.setExemptFeesOut(auctionsOAAddress, true)
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
