const hre = require("hardhat")
require('dotenv').config()

const adminAddress = process.env.ADMIN_ADDRESS

const main = async () => {
  console.log('Running deployWithEthers script...')
  const ERC20OA = await hre.ethers.getContractFactory('ERC20OA')
  const erc20OA = await ERC20OA.deploy(
    'hardhatToken', // Name token
    'hht', // Symbol token
    adminAddress, // Address Admin
    '0x70997970C51812dc3A010C7d01b50e0d17dc79C8', //Address Marketing
    '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', // Address Development
    '0x90F79bf6EB2c4f870365E785982E1f101E93b906', // Helping address,
    '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65', // Rewards Address
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
