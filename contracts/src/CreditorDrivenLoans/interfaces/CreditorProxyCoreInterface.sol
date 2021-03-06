pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "../../shared/libraries/OrderLibrary.sol";
import "../libraries/CreditorProxyErrors.sol";
import "../libraries/CreditorProxyEvents.sol";

contract CreditorProxyCoreInterface is CreditorProxyErrors, CreditorProxyEvents { }
