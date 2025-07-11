// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

contract OnboardImage is OnlyMemberBase {
    event MemberIconRegistered(
        uint256 indexed memberId,
        address indexed account,
        string iconURI,
        bytes iconVerifiedSignature
    );

    function onboardImage(
        string memory ipfsUrl,
        bytes memory signature
    ) external returns (bool) {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        bool isMember = false;
        uint memberId = 0;
        for (uint i; i < $member.nextMemberId; ++i) {
            if ($member.members[i].addr == msg.sender) {
                isMember = true;
                memberId = $member.members[i].id;
                break;
            }
        }
        require(isMember, "You are not a member.");

        Schema.Member storage $m = Storage.$Members().members[memberId];
        $m.iconURI = ipfsUrl;
        $m.iconVerifiedSignature = signature;

        emit MemberIconRegistered(memberId, msg.sender, ipfsUrl, signature);

        return true;
    }
}
