// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import {console2} from "forge-std/console2.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {Types} from "bundle/textDAO/storages/Types.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Propose is OnlyMemberBase {
    function propose(
        Types.ProposalArg calldata _p
    ) external onlyMember returns (uint proposalId) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();

        proposalId = $.nextProposalId;

        Schema.Proposal storage $p = $.proposals[proposalId];
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        for (uint i; i < $member.nextMemberId; ++i) {
            $p.proposalMeta.reps.push($member.members[i].addr);
        }

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        $p.proposalMeta.createdAt = block.timestamp;
        // Note: Shadow(sender, timestamp)

        $.nextProposalId++;
    }
}
