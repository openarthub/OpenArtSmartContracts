const hre = require("hardhat")

const main = async () => {
  console.log('Runnig set_exceed_fees')
  
  const accounts = await hre.ethers.getSigners()
  const ERC20OA = await hre.ethers.getContractFactory("ERC20OA", accounts[5])
  const erc20OA = ERC20OA.attach(
    '0xE6E340D132b5f46d1e472DebcD681B2aBc16e57E' // Deployed contract address
  )

  await erc20OA.setExemptFeesIn("0xD0141E899a65C95a556fE2B27e5982A6DE7fDD7A", true)
  await erc20OA.setExemptFeesOut("0xD0141E899a65C95a556fE2B27e5982A6DE7fDD7A", true)

  await erc20OA.setExemptFeesIn("0xF32D39ff9f6Aa7a7A64d7a4F00a54826Ef791a55", true)
  await erc20OA.setExemptFeesOut("0xF32D39ff9f6Aa7a7A64d7a4F00a54826Ef791a55", true)
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })