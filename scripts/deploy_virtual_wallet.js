const hre = require("hardhat")
require('dotenv').config({ path: `./.env${process.env.ENV ? '.' + process.env.ENV : ''}`})

const adminAddress = process.env.ADMIN_ADDRESS
const erc20Address = process.env.CURRENT_ERC20_ADDRESS

const main = async () => {
  console.log('Running deploy script...')
  const VirtualWallet = await hre.ethers.getContractFactory('VirtualWalletOA')
  const virtualWallet = await VirtualWallet.deploy(
    erc20Address, // ERC20 token Address
    adminAddress // Initial approval
  )

  await virtualWallet.deployed()

  const virtualWalletAddress = virtualWallet.address
  console.log(`Virtual Wallet smart contract deployed at ${virtualWalletAddress}`)

  console.log('Deployment successful.')
} 

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
