const hre = require("hardhat")

const main = async (nameFactory, addressContract, addressToApproval) => {
  console.log('Runnig set_approval')
  
  const accounts = await hre.ethers.getSigners()
  const Contract = await hre.ethers.getContractFactory(nameFactory)
  const contract = Contract.attach(
    addressContract // Deployed contract address
  )

  await contract.setApproval(addressToApproval, true)
}

main ('Minter', '0xa513E6E4b8f2a923D98304ec87F64353C4D5C853', '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266')
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error)
    process.exit(1)
  })
  