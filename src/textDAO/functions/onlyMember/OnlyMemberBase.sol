// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

abstract contract OnlyMemberBase {
    error YouAreNotTheMember();

    modifier onlyMember() {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();
        _;
    }

}
