// Right click on the script name and hit "Run" to execute
const hre = require("hardhat")
require('dotenv').config()

const adminAddress = process.env.ADMIN_ADDRESS
const walletMinter = process.env.ADDRESS_MINTER_WALLET
const walletMarketing = process.env.ADDRESS_MARKETING_WALLET
const walletHelping = process.env.ADDRESS_HELPING_WALLET
const walletRewards = process.env.ADDRESS_REWARDS_WALLET
const walletDevelopment = process.env.ADDRESS_DEVELOPMENT_WALLET
const listingPricePercent = process.env.LISTING_PRICE_PERCENT

const main = async () => {
  console.log('Running deployWithEthers script...')

  /* *** StorageOA *** */
  const StorageOA = await hre.ethers.getContractFactory('StorageOA')
  const storageOA = await StorageOA.deploy(
    '0xBfA7e689B6D989791f35B6AFc2e47cF541BDAA58', // Backup Address
  )

  await storageOA.deployed()
  const storageOAAddress = storageOA.address
  console.log(`StorageOA smart contract deployed at ${storageOAAddress}`)

  /* *** SalesOA *** */
  const SalesOA = await hre.ethers.getContractFactory('SalesOA')
  const salesOA = await SalesOA.deploy(
    listingPricePercent, // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await salesOA.deployed()
  const salesOAAddress = salesOA.address
  console.log(`SalesOA smart contract deployed at ${salesOAAddress}`)

  /* *** AuctionsOA *** */
  const AuctionsOA = await hre.ethers.getContractFactory('AuctionsOA')
  const auctionsOA = await AuctionsOA.deploy(
    listingPricePercent, // Listing price in percent (0 - 100)
    storageOAAddress, // Address of StorageOA contract
  )

  await auctionsOA.deployed()
  const auctionsOAAddress = auctionsOA.address
  console.log(`AuctionsOA smart contract deployed at ${auctionsOAAddress}`)

  /* *** OffersOA *** */
  const OffersOA = await hre.ethers.getContractFactory('OffersOA')
  const offersOA = await OffersOA.deploy(
    listingPricePercent, // Listing price in percent (0 - 100)
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

  console.log(adminAddress, walletDevelopment, walletHelping, walletMarketing, walletRewards)
  const erc20OA = await ERC20OA.deploy(
    'GanacheToken', // Name token
    'GT', // Symbol token
    adminAddress, // Address Admin
    walletMarketing, //Address Marketing
    walletDevelopment, // Address Development
    walletHelping, // Helping address,
    walletRewards, // Rewards Address
  )

  await erc20OA.deployed()

  const erc20OAAddress = erc20OA.address
  console.log(`ERC20OA smart contract deployed at ${erc20OAAddress}`)


    /* *** MinterOA *** */
    const MinterOA = await hre.ethers.getContractFactory('Minter')
    const minterOA = await MinterOA.deploy(
      walletMinter, // Listing price in percent (0 - 100)
      storageOAAddress, // Address of StorageOA contract
      adminAddress, // Addres that is gonna recive earns
    )
  
    await minterOA.deployed()
    const minterOAAddress = minterOA.address
    console.log(`minterOA smart contract deployed at ${minterOAAddress}`)
  
    console.log('Deployment successful.')
  

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
  console.log('first set')
  await erc20OA.setExemptFeesOut(offersOAAddress, true)
  console.log('second set')

  await erc20OA.setExemptFeesIn(salesOAAddress, true)
  console.log('thirdth set')
  await erc20OA.setExemptFeesOut(salesOAAddress, true)
  console.log('forth set')

  await erc20OA.setExemptFeesIn(auctionsOAAddress, true)
  console.log('fiveth set')
  await erc20OA.setExemptFeesOut(auctionsOAAddress, true)
  console.log('sixth set')

  console.log(`REACT_APP_NFT_MARKET_ADDRESS=${openArtMarketPlaceAddress}`)
  console.log(`REACT_APP_AUCTIONS_ADDRESS=${auctionsOAAddress}`)
  console.log(`REACT_APP_SALES_ADDRESS=${salesOAAddress}`)
  console.log(`REACT_APP_STORAGE_ADDRESS=${storageOAAddress}`)
  console.log(`REACT_APP_OFFERS_ADDRESS=${offersOAAddress}`)
  console.log(`REACT_APP_NFT_ADDRESS=${erc721OAAddress}`)
  console.log(`REACT_APP_ERC20_ADDRESS=${erc20OAAddress}`)
  console.log('\n \n \n')
  console.log(`ADDRESS_MINTER_CONTRACT=${minterOAAddress}`)
  console.log('\n \n \n')
  console.log(`CURRENT_OFFERS_ADDRESS=${offersOAAddress}`)
  console.log(`CURRENT_AUCTIONS_ADDRESS=${auctionsOAAddress}`)
  console.log(`CURRENT_SALES_ADDRESS=${salesOAAddress}`)
  console.log(`CURRENT_STORAGE_ADDRESS=${storageOAAddress}`)
  console.log(`CURRENT_MAIN_ADDRESS=${openArtMarketPlaceAddress}`)
  console.log(`CURRENT_MINTER_ADDRESS=${minterOAAddress}`)
  console.log(`CURRENT_ERC20_ADDRESS=${erc20OAAddress}`)

}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
