const fs = require("fs");
const colors = require("colors");
const { ethers } = require("hardhat");
const SFCAbi =
	require("../artifacts/contracts/sfc/SFC.sol/SFC.json").abi;

async function main() {
	// get network
	var [deployer,sfcOwner] = await ethers.getSigners();

	let network = await deployer.provider._networkPromise;
	let chainId = network.chainId;

	console.log(chainId,deployer.address);

    var sICICB;
    var stakeTokenizer;

    var stakerInfo;

    /* ----------- sICICB -------------- */
    //deploy SICICB contract for test
    const SICICB = await ethers.getContractFactory("SICICB");
    sICICB = await SICICB.deploy();
    await sICICB.deployed();

    const StakeTokenizer = await ethers.getContractFactory("StakeTokenizer");
    stakeTokenizer = await StakeTokenizer.deploy(sICICB.address);
    await stakeTokenizer.deployed();

    var tx = await sICICB.addMinter(stakeTokenizer.address);
    await tx.wait();

    // stakerInfo
    const StakerInfo = await ethers.getContractFactory("StakerInfo");
    stakerInfo = await StakerInfo.deploy();
    await stakerInfo.deployed();

    //sfc 

    // const sFC = new ethers.Contract("0x1c1cB00000000000000000000000000000000000",SFCAbi,sfcOwner);
    // tx = await sFC.updateStakeTokenizerAddress(stakeTokenizer.address);
    // await tx.wait();

    console.log("SICICB : ",sICICB.address);
    console.log("StakeTokenizer : ",stakeTokenizer.address);
    console.log("StakerInfo : ",stakerInfo.address);

}

main()
	.then(() => {
		console.log("complete".green);
	})
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
