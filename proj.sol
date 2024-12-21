// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicalEducationSimulations {

    address public admin;  // Admin address
    uint public rewardAmount;  // Reward amount per simulation completion (in wei)
    
    // Participant structure
    struct Participant {
        bool registered;
        uint simulationsCompleted;
        uint totalRewardEarned;
    }
    
    // Mapping of participants by address
    mapping(address => Participant) public participants;

    // Event to log when a user completes a simulation
    event SimulationCompleted(address indexed participant, uint reward);

    // Modifier to ensure only the admin can call certain functions
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to ensure the participant is registered
    modifier onlyRegistered() {
        require(participants[msg.sender].registered, "You must be registered to participate");
        _;
    }

    // Constructor to initialize the contract
    constructor(uint _rewardAmount) {
        admin = msg.sender;  // Set the contract deployer as admin
        rewardAmount = _rewardAmount;  // Set reward amount
    }

    // Function to register a participant
    function register() external {
        require(!participants[msg.sender].registered, "Already registered");
        participants[msg.sender].registered = true;
    }

    // Function for a participant to complete a simulation
    function completeSimulation() external onlyRegistered {
        participants[msg.sender].simulationsCompleted += 1;
        participants[msg.sender].totalRewardEarned += rewardAmount;
        
        // Transfer reward (in wei) to the participant's wallet
        payable(msg.sender).transfer(rewardAmount);
        
        // Emit event
        emit SimulationCompleted(msg.sender, rewardAmount);
    }

    // Admin function to update reward amount
    function setRewardAmount(uint _rewardAmount) external onlyAdmin {
        rewardAmount = _rewardAmount;
    }

    // Admin function to withdraw funds from the contract (for admin purposes)
    function withdraw(uint _amount) external onlyAdmin {
        payable(admin).transfer(_amount);
    }

    // Fallback function to accept ether deposits
    receive() external payable {}

    // Function to view participant details
    function getParticipantDetails(address participant) external view returns (bool registered, uint simulationsCompleted, uint totalRewardEarned) {
        Participant memory p = participants[participant];
        return (p.registered, p.simulationsCompleted, p.totalRewardEarned);
    }
}
