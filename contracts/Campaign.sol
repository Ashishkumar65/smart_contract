// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum, string memory name, string memory description, string memory image, uint target) public {
        address newCampaign = address(new Campaign(minimum, msg.sender, name, description, image, target));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    string public campaignName;
    string public campaignDescription;
    string public imageUrl;
    uint public targetToAchieve;
    address[] public contributors;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager, "Caller is not the manager");
        _;
    }

    constructor(uint minimum, address creator, string memory name, string memory description, string memory image, uint target) {
        manager = creator;
        minimumContribution = minimum;
        campaignName = name;
        campaignDescription = description;
        imageUrl = image;
        targetToAchieve = target;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution, "Contribution amount is less than minimum required");
        contributors.push(msg.sender);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string memory description, uint value, address recipient) public restricted {
        Request storage newRequest = requests.push();
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender], "Only approvers can approve requests");
        require(!requests[index].complete, "Request is already completed");
        require(!requests[index].approvals[msg.sender], "Request already approved by this approver");

        requests[index].approvals[msg.sender] = true;
        requests[index].approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        require(requests[index].approvalCount > (approversCount / 2), "Not enough approvals for finalization");
        require(!requests[index].complete, "Request is already completed");

        payable(requests[index].recipient).transfer(requests[index].value);
        requests[index].complete = true;
    }

    function getSummary() public view returns (uint, uint, uint, uint, address, string memory, string memory, string memory, uint) {
        return (
            minimumContribution,
            address(this).balance,
            requests.length,
            approversCount,
            manager,
            campaignName,
            campaignDescription,
            imageUrl,
            targetToAchieve
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
}
