const { ethers } = require("hardhat")
const hre = require("hardhat")
require('dotenv').config()


const main = async () => {
  console.log('Running deployWithEthers script...')
  const provider = hre.ethers.provider
  const accounts = await hre.ethers.getSigners()
  console.log('0:', accounts[0].address, (ethers.utils.formatEther(await provider.getBalance(accounts[0].address))).toString())
  console.log('1:', accounts[1].address, (ethers.utils.formatEther(await provider.getBalance(accounts[1].address))).toString())
  console.log('2:', accounts[2].address, (ethers.utils.formatEther(await provider.getBalance(accounts[2].address))).toString())
  console.log('3:', accounts[3].address, (ethers.utils.formatEther(await provider.getBalance(accounts[3].address))).toString())
  console.log('4:', accounts[4].address, (ethers.utils.formatEther(await provider.getBalance(accounts[4].address))).toString())
  console.log('5:', accounts[5].address, (ethers.utils.formatEther(await provider.getBalance(accounts[5].address))).toString())
  console.log('6:', accounts[6].address, (ethers.utils.formatEther(await provider.getBalance(accounts[6].address))).toString())
  console.log('7:', accounts[7].address, (ethers.utils.formatEther(await provider.getBalance(accounts[7].address))).toString())
  console.log('8:', accounts[8].address, (ethers.utils.formatEther(await provider.getBalance(accounts[8].address))).toString())
  console.log('9:', accounts[9].address, (ethers.utils.formatEther(await provider.getBalance(accounts[9].address))).toString())
  console.log('10:', accounts[10].address, (ethers.utils.formatEther(await provider.getBalance(accounts[10].address))).toString())
  console.log('11:', accounts[11].address, (ethers.utils.formatEther(await provider.getBalance(accounts[11].address))).toString())
  console.log('12:', accounts[12].address, (ethers.utils.formatEther(await provider.getBalance(accounts[12].address))).toString())
  console.log('13:', accounts[13].address, (ethers.utils.formatEther(await provider.getBalance(accounts[13].address))).toString())
  console.log('14:', accounts[14].address, (ethers.utils.formatEther(await provider.getBalance(accounts[14].address))).toString())
  console.log('15:', accounts[15].address, (ethers.utils.formatEther(await provider.getBalance(accounts[15].address))).toString())
  console.log('16:', accounts[16].address, (ethers.utils.formatEther(await provider.getBalance(accounts[16].address))).toString())
  console.log('17:', accounts[17].address, (ethers.utils.formatEther(await provider.getBalance(accounts[17].address))).toString())
  console.log('18:', accounts[18].address, (ethers.utils.formatEther(await provider.getBalance(accounts[18].address))).toString())
  console.log('19:' ,accounts[19].address, (ethers.utils.formatEther(await provider.getBalance(accounts[19].address))).toString())
} 

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
