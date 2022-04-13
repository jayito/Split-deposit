async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const DepositSplit = await ethers.getContractFactory("DepositSplit");
    const depositSplit = await DepositSplit.deploy();

    console.log("DepositSplit address:", depositSplit.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });