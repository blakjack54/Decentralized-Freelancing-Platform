// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Freelancing {
    struct Job {
        address client;
        address freelancer;
        string description;
        uint256 payment;
        bool completed;
    }

    uint256 public jobCount;
    mapping(uint256 => Job) public jobs;

    event JobPosted(uint256 jobId, address client, string description, uint256 payment);
    event JobTaken(uint256 jobId, address freelancer);
    event JobCompleted(uint256 jobId);

    function postJob(string memory description) external payable {
        require(msg.value > 0, "Payment must be greater than zero");

        jobCount++;
        jobs[jobCount] = Job(msg.sender, address(0), description, msg.value, false);
        emit JobPosted(jobCount, msg.sender, description, msg.value);
    }

    function takeJob(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(job.freelancer == address(0), "Job already taken");

        job.freelancer = msg.sender;
        emit JobTaken(jobId, msg.sender);
    }

    function completeJob(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.freelancer, "Only assigned freelancer can complete the job");
        require(!job.completed, "Job already completed");

        job.completed = true;
        payable(job.freelancer).transfer(job.payment);
        emit JobCompleted(jobId);
    }

    function getJob(uint256 jobId) external view returns (address client, address freelancer, string memory description, uint256 payment, bool completed) {
        Job storage job = jobs[jobId];
       
