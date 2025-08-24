// scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // VotingToken 컨트랙트 배포
    const VotingToken = await ethers.getContractFactory("VotingToken");
    const votingToken = await VotingToken.deploy();
    await votingToken.waitForDeployment();
    console.log("VotingToken deployed to:", votingToken.target);

    // VoteManager 컨트랙트 배포
    const VoteManager = await ethers.getContractFactory("VoteManager");
    const voteManager = await VoteManager.deploy(votingToken.target);
    await voteManager.waitForDeployment();
    console.log("VoteManager deployed to:", voteManager.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });