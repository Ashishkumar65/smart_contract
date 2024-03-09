const hre = require("hardhat");

async function main() {
  const Campaign = await hre.ethers.getContractFactory("Campaign");

  // Define constructor arguments
  const minimum = 100; // Example value, replace with your desired value
  const creator = "0xYourCreatorAddress"; // Example address, replace with the actual creator's address
  const name = "YourCampaignName"; // Example name, replace with the actual campaign name
  const description = "YourCampaignDescription"; // Example description, replace with the actual campaign description
  const image = "YourImageURL"; // Example image URL, replace with the actual image URL
  const target = 1000; // Example target, replace with your desired target value

  // Deploy the Campaign contract with constructor arguments
  const campaign = await Campaign.deploy(minimum, creator, name, description, image, target);

  // Wait for the contract to be deployed
  await campaign.deployed();

  // Log the deployed contract address
  console.log(`Campaign deployed to ${campaign.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
