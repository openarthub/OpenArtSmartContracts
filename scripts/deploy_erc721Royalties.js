// Right click on the script name and hit "Run" to execute
const hre = require('hardhat');
require('dotenv').config();

const MINTER_ADDRESS = process.env.CURRENT_MINTER_ADDRESS;
const OPENART_ADDRESS = process.env.OPENART_ADDRESS_WALLET;
const MAX_SUPPLY = process.env.MAX_SUPPLY_COLLECTION;

const main = async () => {
  console.log('Running deployWithEthers script...');

  /* *** ERC721OA *** */
  const ERC721OA = await hre.ethers.getContractFactory('FOLEARTMX');
  const erc721OA = await ERC721OA.deploy(
    'Examp', // name
    'FAMX', // symbol
    OPENART_ADDRESS, // Address owner
    MAX_SUPPLY_COLLECTION, // max supply
  );

  await erc721OA.deployed();
  const erc721OAAddress = erc721OA.address;
  console.log(`ERC721OA smart contract deployed at ${erc721OAAddress}`);
  await erc721OA.setApproval(MINTER_ADDRESS, true);
  console.log('setted');
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
