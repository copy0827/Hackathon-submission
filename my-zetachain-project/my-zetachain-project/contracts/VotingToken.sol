// contracts/VotingToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VotingToken is ERC20 {
    constructor() ERC20("Vote Token", "VOTE") {}

    // 이 함수는 투표권을 유권자에게 분배하는 데 사용됩니다.
    function mint(address to, uint256 amount) public {
        // 실제 프로젝트에서는 접근 제어(onlyOwner 등)를 추가해야 합니다.
        _mint(to, amount);
    }
}