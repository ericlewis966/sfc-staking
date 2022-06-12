const fs = require("fs");
const colors = require("colors");
const { ethers } = require("hardhat");
const SFCAbi =
	require("../artifacts/contracts/sfc/SFC.sol/SFC.json").abi;

async function main() {
	// get network
	var [sfcOwner] = await ethers.getSigners();

	let network = await sfcOwner.provider._networkPromise;
	let chainId = network.chainId;

	console.log(chainId,sfcOwner.address);

    var stakeTokenizer = {address : "0x08d7a2622aA89fc9ae356A3E9d9d31A314f43cF4"};

    const sFC = new ethers.Contract("0x1c1cB00000000000000000000000000000000000",SFCAbi,sfcOwner);
    var tx = await sFC.updateStakeTokenizerAddress(stakeTokenizer.address);
    await tx.wait();

    console.log("sFC : ",tx.hash);

}

main()
	.then(() => {
		console.log("complete".green);
	})
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
