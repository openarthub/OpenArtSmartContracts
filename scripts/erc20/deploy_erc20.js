const deployERC20 = async (wallet) => {
  const erc20OA = await deployContract(
    wallet,
    erc20Artifact,
    [
      'ganacheToken', // Name token
      'gnc', // Symbol token
      wallet.address, // Address Admin
      '0x4e34EeC85C800Fc61829b1b50Edb0a45f57BB632', //Address Marketing
      '0x33f99cC965Ea46A44eAc7d4fDAff91429Ee4E43a', // Address Development
      '0x31c6683a2f80B17c9576a39554505CBdCb80501e', // Helping address,
      '0x1EF008Fe5bDEE78b1C2Aafaf60631f40e84B3374', // Rewards Address
    ]
  )

  await erc20OA.deployed()

  const erc20OAAddress = erc20OA.address
  return erc20OA
} 