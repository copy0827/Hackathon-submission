// contracts/VoteManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./VotingToken.sol";

contract VoteManager {
    VotingToken public votingToken;
    mapping(string => uint256) public votes; // 후보자 이름 -> 투표 수
    mapping(address => bool) public hasVoted; // 유권자 주소 -> 투표 여부

    // 생성자에서 투표권 토큰 컨트랙트 주소를 받습니다.
    constructor(address _votingTokenAddress) {
        votingToken = VotingToken(_votingTokenAddress);
    }

    // 투표를 제출하는 함수. 후보자 이름과 투표 토큰을 받습니다.
    function vote(string memory candidateName, uint256 tokenAmount) public {
        require(!hasVoted[msg.sender], "Already voted.");
        
        // [수정] 토큰 전송 전의 잔액을 기록합니다.
        uint256 balanceBefore = votingToken.balanceOf(address(this));
        
        // [수정] 유권자로부터 투표 토큰을 컨트랙트로 전송받습니다.
        // 유권자는 이 함수를 호출하기 전에 'approve'를 먼저 호출해야 합니다.
        votingToken.transferFrom(msg.sender, address(this), tokenAmount);

        // [추가] 토큰 전송 후의 잔액을 확인하여 트랜잭션의 성공 여부를 검증합니다.
        uint256 balanceAfter = votingToken.balanceOf(address(this));
        require(balanceAfter == balanceBefore + tokenAmount, "Token transfer failed.");
        
        // 투표 로직
        votes[candidateName]++;
        hasVoted[msg.sender] = true;
    }
}