const hre = require("hardhat")

const main = async () => {
  console.log('Runnig set_exceed_fees')
  
  const accounts = await hre.ethers.getSigners()
  const ERC20OA = await hre.ethers.getContractFactory("ERC20OA")
  const erc20OA = ERC20OA.attach(
    '0xAec0eb126B933C3Ae25250e6683b7b46Cd9637Ad' // Deployed contract address
  )

  await erc20OA.setExemptFeesIn("0x0e486ACF8B867AA79361E9346C4918cf7B5cd7CD", true)
  await erc20OA.setExemptFeesOut("0x0e486ACF8B867AA79361E9346C4918cf7B5cd7CD", true)

  await erc20OA.setExemptFeesIn("0xE8b0f5B2036FaaCe506f20bb9829F88aE60D2d22", true)
  await erc20OA.setExemptFeesOut("0xE8b0f5B2036FaaCe506f20bb9829F88aE60D2d22", true)
}

main ()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })