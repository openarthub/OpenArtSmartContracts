const hre = require("hardhat")
require('dotenv').config()

const adminAddress = process.env.ADMIN_ADDRESS

const main = async () => {
  console.log('Running deployWithEthers script...')
  const ERC20OA = await hre.ethers.getContractFactory('ERC20OA')
  const erc20OA = await ERC20OA.deploy(
    'ganacheToken', // Name token
    'gnc', // Symbol token
    adminAddress, // Address Admin
    '0x4e34EeC85C800Fc61829b1b50Edb0a45f57BB632', //Address Marketing
    '0x33f99cC965Ea46A44eAc7d4fDAff91429Ee4E43a', // Address Development
    '0x31c6683a2f80B17c9576a39554505CBdCb80501e', // Helping address,
    '0x1EF008Fe5bDEE78b1C2Aafaf60631f40e84B3374', // Rewards Address
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
