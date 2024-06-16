// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";

// External getter functions
contract Getter {
    struct ProposalInfo {
        Schema.ProposalMeta proposalMeta;
        uint256 headersLength;
        uint256 cmdsLength;
    }
    function getProposal(uint id) external view returns (ProposalInfo memory) {
        Schema.Proposal storage proposal = Storage.$Proposals().proposals[id];
        return ProposalInfo({
            headersLength: proposal.headers.length,
            cmdsLength: proposal.cmds.length,
            proposalMeta: proposal.proposalMeta
        });
    }

    function getProposalHeaders(uint pid) external view returns(Schema.Header[] memory) {
        return Storage.$Proposals().proposals[pid].headers;
    }

    function getProposalCommand(uint pid, uint cid) external view returns(Schema.Command memory) {
        return Storage.$Proposals().proposals[pid].cmds[cid];
    }

    function getNextProposalId() external view returns (uint) {
        return Storage.$Proposals().nextProposalId;
    }

    function getProposalsConfig() external view returns (Schema.ProposalsConfig memory) {
        return Storage.$Proposals().config;
    }

    function getText(uint id) external view returns (Schema.Text memory) {
        return Storage.$Texts().texts[id];
    }

    function getNextTextId() external view returns (uint) {
        return Storage.$Texts().nextTextId;
    }

    function getMember(uint id) external view returns (Schema.Member memory) {
        for (uint i; i < Storage.$Members().nextMemberId; i++) {
            if (Storage.$Members().members[i].id == id) {
                return Storage.$Members().members[i];
            }
        }
        return Schema.Member(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, address(0), "");
        
        // return Storage.$Members().members[id];
    }

    function getNextMemberId() external view returns (uint) {
        return Storage.$Members().nextMemberId;
    }

    function getVRFRequest(uint id) external view returns (Schema.Request memory) {
        return Storage.$VRF().requests[id];
    }

    function getNextVRFId() external view returns (uint) {
        return Storage.$VRF().nextId;
    }

    function getSubscriptionId() external view returns (uint64) {
        return Storage.$VRF().subscriptionId;
    }

    function getVRFConfig() external view returns (Schema.VRFConfig memory) {
        return Storage.$VRF().config;
    }

    function getConfigOverride(bytes4 sig) external view returns (Schema.ConfigOverride memory) {
        return Storage.$ConfigOverride().overrides[sig];
    }
}
