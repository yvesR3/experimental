pragma solidity ^0.4.25;

import "./DecisionEngines/NaiveDecisionEngine.sol";
import "./interfaces/CreditorProxyCoreInterface.sol";


contract NaiveCreditorProxy is NaiveDecisionEngine, CreditorProxyCoreInterface {

    mapping (bytes32 => bool) public debtOfferCancelled;
    mapping (bytes32 => bool) public debtOfferFilled;

    bytes32 constant internal NULL_ISSUANCE_HASH = bytes32(0);

    function fillDebtOffer(DebtOrder memory order) public whenNotPaused returns (bytes32 id) {
        (isConsensual, id) = evaluateConsent(order);

        if (!isConsensual) {
            return NULL_ISSUANCE_HASH;
        }

        debtOfferFilled[id] = true;

        return id;
    }

    function cancelDebtOffer(DebtOrder memory order) public whenNotPaused returns (bool) {
        // sender must be the creditor.
        require(msg.sender == order.creditor);

        bytes32 id = hashCreditorCommitmentForOrder(order);

        // debt offer must not already be filled.
        require(!debtOfferFilled[id]);

        debtOfferCancelled[id] = true;

        return true;
    }

}
