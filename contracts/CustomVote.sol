pragma solidity ^0.8.0;

contract CustomVote {

    struct Voter {
        bool voted;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
        address addrezz;
    }

    struct FinishState {
        uint winningProposal;
        uint count;
    }

    uint public auctionAvailableToEndTime;
    address payable public chairperson;
    bool ended;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    uint256 public cost = 0.01 ether;

    error VoteNotYetEnded();
    error VoteAlreadyEnded();

    constructor(
        bytes32[] memory proposalNames,
        address[] addresses
    ) {
        chairperson = msg.sender;
        auctionAvailableToEndTime = block.timestamp + 3 days;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
            name: proposalNames[i],
            voteCount: 0,
            addrezz: addresses[i]
            }));
        }
    }

    function vote(uint proposal) external payable {
        if (ended)
            revert VoteAlreadyEnded();
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += 1;
    }

    function withdrawCommission() external {
        require(
            ended,
            "The vote has not already finished."
        );
        require(
            msg.sender == chairperson,
            "Only chairperson can withdraw commission."
        );

        chairperson.transfer(highestBid);
    }

    function voteEnd() external {
        if (block.timestamp < auctionEndTime)
            revert VoteNotYetEnded();
        if (ended)
            revert VoteAlreadyEnded();

        ended = true;
        Proposal winner = proposals[winningProposal()];
        payable(winner.addrezz).transfer(count * cost * 0.09);
    }

    function winningProposal() internal
    returns (FinishState state)
    {
        uint winningVoteCount = 0;
        uint winningProposal_ = -1;
        uint count_ = 0;
        for (uint p = 0; p < proposals.length; p++) {
            count_ = count_ + proposals[p].voteCount;
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
        state = FinishState({
            winningProposal: winningProposal_,
            count: count_
            });
    }


}
