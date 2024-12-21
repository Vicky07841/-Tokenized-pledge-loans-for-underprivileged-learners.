// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {
    // Events
    event LoanPledged(address indexed learner, uint256 amount, string course);
    event LoanRedeemed(address indexed learner, uint256 amount);
    event CourseCompleted(address indexed learner, string course);

    // Structs
    struct Pledge {
        uint256 amount;
        string course;
        bool redeemed;
    }

    // State Variables
    address public owner;
    mapping(address => Pledge[]) public learnerPledges;
    mapping(address => uint256) public learnerEarnings;

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Function to pledge loan for learners
    function pledgeLoan(address _learner, uint256 _amount, string memory _course) external onlyOwner {
        require(_amount > 0, "Amount must be greater than zero");
        learnerPledges[_learner].push(Pledge({
            amount: _amount,
            course: _course,
            redeemed: false
        }));

        emit LoanPledged(_learner, _amount, _course);
    }

    // Function to redeem loan after course completion
    function redeemLoan(uint256 _index) external {
        require(_index < learnerPledges[msg.sender].length, "Invalid pledge index");
        Pledge storage pledge = learnerPledges[msg.sender][_index];
        require(!pledge.redeemed, "Pledge already redeemed");

        learnerEarnings[msg.sender] += pledge.amount;
        pledge.redeemed = true;

        emit LoanRedeemed(msg.sender, pledge.amount);
    }

    // Function to mark course completion
    function completeCourse(string memory _course) external {
        emit CourseCompleted(msg.sender, _course);
    }

    // Function to check total earnings of a learner
    function getEarnings(address _learner) external view returns (uint256) {
        return learnerEarnings[_learner];
    }

    // Function to withdraw earnings
    function withdrawEarnings() external {
        uint256 amount = learnerEarnings[msg.sender];
        require(amount > 0, "No earnings to withdraw");
        learnerEarnings[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }

    // Function to deposit funds into the contract
    function deposit() external payable onlyOwner {}

    // Fallback function to receive Ether
    receive() external payable {}
}
