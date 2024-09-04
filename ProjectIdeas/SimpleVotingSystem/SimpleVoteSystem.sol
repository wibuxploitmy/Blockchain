// SPDX-License-Identifier: WXP

pragma solidity ^0;


contract votingSystem {

        // Simple onlyOwner
        address internal owner;
        modifier onlyOwner() {
                require(msg.sender==owner,"Not authorized: Only owner can call this function");
                _;
        }

        // Simple isActiveVoting
        bool internal votingActive = true;
        modifier isActiveVoting() {
                require(votingActive, "Voting is currently stopped.");
                _;
        }

        // Emergency Stop Voting
        function emergencyStop() public onlyOwner{
                votingActive = false;
                for (uint i = 0; i < Candidates.length; i++) {
                        Candidates[i].VOTE = 0;
                }
        }

        // Restart Voting
        function restartVoting() public onlyOwner {
                votingActive = true;
                for (uint i = 0; i < Candidates.length; i++) {
                        Candidates[i].VOTE = 0;
                }
        }

        struct CandidateData {
                int256 ID;
                string NAME;
                int VOTE;
        }

        // Voter Structure Data
        struct VoterData {
                address[] AID;
                bool VOTED;
                int256 DELEGATION;
        }

        // List of Candidate
        CandidateData[] internal Candidates;

        constructor() {
                owner = msg.sender;
                Candidates.push(CandidateData(1,"Alex",0));
                Candidates.push(CandidateData(2,"Bo jang",0));
        }

        // New Candidate
        function newCandidate(int256 id, string memory name) public onlyOwner {
                Candidates.push(CandidateData(id, name, 0));
        }

        // Remove Candidate
        function removeCandidate(int256 id) public onlyOwner {
                for (uint i = 0; i < Candidates.length; i++) {
                        if (Candidates[i].ID == id) {
                                Candidates[i] = Candidates[Candidates.length - 1];
                                Candidates.pop();
                                break;
                        }
                }
        }

        // Check if Candidate ID is valid
        function validCandidate(int256 id) internal view returns (bool) {
                for (uint i = 0; i < Candidates.length; i++) {
                        if (Candidates[i].ID == id) {
                                return true;
                        }
                }
                return false;
        }

        // Mapping
        mapping(address => VoterData) internal Voters;
        mapping(int256 => CandidateData) internal Candidate;
        mapping(address => bool) internal blacklist;

        // Event
        event logVote(address indexed voter, int indexed candidateId, uint indexed timestamp);

        // Blacklist function
        function addToBlacklist(address _address) public onlyOwner {
                blacklist[_address] = true;
        }
        function RemoveBlacklist(address _address) public onlyOwner {
                blacklist[_address] = false;
        }

        function vote(int id) public isActiveVoting {
                // Check if already vote
                require(!blacklist[msg.sender], "Address is blacklisted and cannot participate");
                require(!Voters[msg.sender].VOTED,"You have already voted.");
                require(validCandidate(id),"Invalid Candidate ID.");

                // Push to list
                Candidate[id].VOTE += 1;
                Voters[msg.sender].DELEGATION = id;

                for(uint i = 0;i < Candidates.length; i++){
                        if(Candidates[i].ID==id){
                                Candidates[i].VOTE += 1;
                                break;
                        }
                }

                Voters[msg.sender].VOTED = true;
                Voters[msg.sender].AID.push(msg.sender);
                emit logVote(msg.sender, id, block.timestamp);

        }

        // Change vote
        function changeCandidateVote(int256 ChangeID) public isActiveVoting {
                require(!blacklisted[msg.sender], "Address is blacklisted and cannot participate");
                require(Voters[msg.sender].VOTED,"You have not voted yet");
                require(validCandidate(ChangeID),"Invalid Candidate ID.");

                // Old Candidate Vote ID
                int256 oldVote = Voters[msg.sender].DELEGATION;

                // Decrease old candidate vote
                for (uint i = 0; i < Candidates.length; i++) {
                        if (Candidates[i].ID == oldVote) {
                                Candidates[i].VOTE -= 1;
                                break;
                        }
                }

                // Increase new candidate vote
                for (uint i = 0; i < Candidates.length; i++) {
                        if (Candidates[i].ID == ChangeID) {
                                Candidates[i].VOTE += 1;
                                break;
                        }
                }

                // Update voter delegation ID
                Voters[msg.sender].DELEGATION = ChangeID;
                emit logVote(msg.sender, ChangeID, block.timestamp);

        }

        // View Rank Live
        function Rank() public view isActiveVoting returns (CandidateData[] memory) {
                CandidateData[] memory Ranked = Candidates;
                for (uint256 i = 0; i < Ranked.length; i++) {
                        for (uint256 j = 0; j < Ranked.length - i - 1; j++) {
                                if (Ranked[j].VOTE < Ranked[j + 1].VOTE) {
                                        CandidateData memory temp = Ranked[j];
                                        Ranked[j] = Ranked[j + 1];
                                        Ranked[j + 1] = temp;
                                }
                        }
                }

                return Ranked;
        }

}
