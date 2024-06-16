// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

import "forge-std/console.sol";


contract Vote is OnlyMemberBase {
    function voteHeaders(uint pid, uint[3] calldata headerIds) external returns (bool) {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        console.log("msg.sender = %s", msg.sender);
        bool isMember = false;
        for (uint i; i < $member.nextMemberId; ++i) {
            console.log("$member.members = %s", $member.members[i].addr);
            if ($member.members[i].addr == msg.sender) {
                isMember = true;
                break;
            }
        }
        require(isMember, "You are not a member.");

        console.log("isMember = %s", isMember);


        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];
        console.log("headerIds = %s", headerIds.length);
        console.log("$p.headers = %s", $p.headers.length);

        require($p.headers.length > 0, "No headers for this proposal.");
        
        $p.headers[headerIds[0]].currentScore += 1;
    }

    function voteCmds(uint pid, uint[3] calldata cmdIds) external returns (bool) {
        Schema.Proposal storage $p = Storage.$Proposals().proposals[pid];

        require($p.cmds.length > 0, "No cmds for this proposal.");

        if ($p.cmds[0].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
        } else if ($p.cmds[1].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
        } else {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
            $p.cmds[cmdIds[2]].currentScore += 1;
        }
    }

}
