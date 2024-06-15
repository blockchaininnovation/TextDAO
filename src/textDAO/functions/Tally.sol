// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";
import { SortLib } from "bundle/_utils/SortLib.sol";
import { SelectorLib } from "bundle/_utils/SelectorLib.sol";

contract Tally {
    function tally(uint pid) external onlyOncePerInterval(pid) returns (bool) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        Schema.Header[] storage $headers = $p.headers;

        Types.ProposalVars memory vars;

        require($p.proposalMeta.createdAt + $.config.expiryDuration > block.timestamp, "This proposal has been expired. You cannot run new tally to update ranks.");

        vars.headerRank = new uint[]($headers.length);
        vars.headerRank = SortLib.rankHeaders($headers, $p.proposalMeta.nextHeaderTallyFrom);

        uint headerTopScore = $headers[vars.headerRank[0]].currentScore;
        bool headerCond = headerTopScore >= $.config.quorumScore;


        if ($p.proposalMeta.headerRank.length == 0) {
            $p.proposalMeta.headerRank = new uint[](3);
        }
        if (headerCond) {
            $p.proposalMeta.headerRank[0] = vars.headerRank[0];
            $p.proposalMeta.headerRank[1] = vars.headerRank[1];
            $p.proposalMeta.headerRank[2] = vars.headerRank[2];
            $p.proposalMeta.nextHeaderTallyFrom = $headers.length;
        } else {
            // emit HeaderQuorumFailed
        }

        // Repeatable tally
        for (uint i = 0; i < 3; ++i) {
            vars.headerRank2 = $p.proposalMeta.headerRank[i];

            // Copy top ranked Headers and Commands to temporary arrays
            if(vars.headerRank2 < $p.headers.length){
                vars.topHeaders[i] = $p.headers[vars.headerRank2];
            }

        }

        // Re-populate with top ranked items
        // next{Header,Cmd}TallyFrom effectively remains these top-3 elements
        for (uint i = 0; i < 3; ++i) {
            $p.headers[vars.headerRank2].id = vars.topHeaders[i].id;
            $p.headers[vars.headerRank2].currentScore = vars.topHeaders[i].currentScore;
            $p.headers[vars.headerRank2].metadataURI = vars.topHeaders[i].metadataURI;
            for (uint j; j < vars.topHeaders[i].tagIds.length; j++) {
                $p.headers[vars.headerRank2].tagIds[j] = vars.topHeaders[i].tagIds[j];
            }
        }

        // interval flag
        require($.config.tallyInterval > 0, "Set tally interval at config.");
        $p.tallied[block.timestamp / $.config.tallyInterval] = true;
    }

    modifier onlyOncePerInterval(uint pid) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        require($.config.tallyInterval > 0, "Set tally interval at config.");
        require(!$p.tallied[block.timestamp / $.config.tallyInterval], "This interval is already tallied.");
        _;
    }
}
