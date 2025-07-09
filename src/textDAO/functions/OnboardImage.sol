// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";


contract OnboardImage is OnlyMemberBase {
    function onboardImage(string memory ipfsUrl, bytes memory signature) external returns (bool) {
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
        require($m.addr == msg.sender, "You are not the member.");
        $m.iconURI = ipfsUrl;
        $m.iconVerifiedSignature = signature;
        
    }


}
