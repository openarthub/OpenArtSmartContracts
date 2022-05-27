const hre = require("hardhat")

const main = async () => {
  console.log('Runnig set_exceed_fees')
  
  const accounts = await hre.ethers.getSigners()
  const ERC20OA = await hre.ethers.getContractFactory("ERC20OA", accounts[5])
  const erc20OA = ERC20OA.attach(
    '0xE6E340D132b5f46d1e472DebcD681B2aBc16e57E' // Deployed contract address
  )

  await erc20OA.setExemptFeesIn("0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", true)
  await erc20OA.setExemptFeesOut("0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", true)

  await erc20OA.setExemptFeesIn("0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9", true)
  await erc20OA.setExemptFeesOut("0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9", true)
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })