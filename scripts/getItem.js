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
  const OpenArtMarketPlace = await (await hre.ethers.getContractFactory('OpenArtMarketPlace')).attach('0xFf6fCd0AFcA6E452E37d17ad773b7774DfbBfe33')
  const item = await OpenArtMarketPlace.getItem(1);
  console.log('endtime: ', item.endTime.toString())
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
