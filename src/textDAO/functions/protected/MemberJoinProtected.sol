// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { ProtectionBase } from "bundle/_utils/ProtectionBase.sol";

contract MemberJoinProtected is ProtectionBase {
    function memberJoin(Schema.Member[] memory candidates) public returns (bool) {
        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();

        for (uint i; i < candidates.length; i++) {
            for (uint j; j < $.nextMemberId; j++) {
                require($.members[j].id != candidates[i].id, "Member ID already exists.");
                require($.members[j].addr != candidates[i].addr, "Address already exists.");
            }
            $.members[$.nextMemberId+i].id = candidates[i].id;
            $.members[$.nextMemberId+i].addr = candidates[i].addr;
            $.members[$.nextMemberId+i].metadataURI = candidates[i].metadataURI;
        }
        $.nextMemberId = $.nextMemberId + candidates.length;
    }
}
