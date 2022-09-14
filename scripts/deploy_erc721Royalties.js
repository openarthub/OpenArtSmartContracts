// Right click on the script name and hit "Run" to execute
const hre = require('hardhat');

const main = async () => {
  console.log('Running deployWithEthers script...');

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory('FOLEARTMX');
  const erc721OA = await ERC721OA.deploy(
    'Examp', // name
    'FAMX', // symbol
    '0x794Fed8D9bEe97a7e352e4C308Cec5632b741104', // Address owner
    1, // max supply
  );

  await erc721OA.deployed();
  const erc721OAAddress = erc721OA.address;
  console.log(`ERC721OA smart contract deployed at ${erc721OAAddress}`);
  await erc721OA.setApproval('0x63594Ca39d89dfD0EB5E310AC20353538088c5d9', true);
  console.log('setted');
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
