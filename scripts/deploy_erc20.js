const hre = require("hardhat")
require('dotenv').config()

const adminAddress = process.env.ADMIN_ADDRESS
const marketingAddress = process.env.ADDRESS_MARKETING_WALLET
const developmentAddress = process.env.ADDRESS_DEVELOPMENT_WALLET
const helpingAddress = process.env.ADDRESS_HELPING_WALLET
const rewardsAddress = process.env.ADDRESS_REWARDS_WALLET

const main = async () => {
  console.log('Running deployWithEthers script...')
  const ERC20OA = await hre.ethers.getContractFactory('ERC20OA')
  const erc20OA = await ERC20OA.deploy(
    'ganacheToken', // Name token
    'gnc', // Symbol token
    adminAddress, // Address Admin
    marketingAddress, //Address Marketing
    developmentAddress, // Address Development
    helpingAddress, // Helping address,
    rewardsAddress, // Rewards Address
  )

  await erc20OA.deployed()

  const erc20OAAddress = erc20OA.address
  console.log(`ERC20OA smart contract deployed at ${erc20OAAddress}`)

  console.log('Deployment successful.')
} 

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
