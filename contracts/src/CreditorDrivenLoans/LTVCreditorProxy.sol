pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./DecisionEngines/LTVDecisionEngine.sol";


contract LTVCreditorProxy is
	LTVDecisionEngine
{

	mapping (bytes32 => bool) public debtOfferCancelled;
	mapping (bytes32 => bool) public debtOfferFilled;

	bytes32 constant internal NULL_ISSUANCE_HASH = bytes32(0);

	function fillDebtOffer(LTVDecisionEngineTypes.Params params)
		public returns (bytes32 id)
	{
		bool isConsensual;

		(isConsensual, id) = evaluateConsent(params);

		if (!(isConsensual && evaluateDecision(params))) {
			return NULL_ISSUANCE_HASH;
		}

		// The order is consensual and has an acceptable LTV ratio.
		debtOfferFilled[id] = true;
		return id;
	}

	function cancelDebtOffer(LTVDecisionEngineTypes.Params params) public returns (bool) {
		// sender must be the creditor.
		require(msg.sender == order.creditor);

		LTVDecisionEngineTypes.CommitmentValues memory commitmentValues = params.creditorCommitment.values;
		OrderLibrary.DebtOrder memory order = params.order;

		bytes32 id = hashOrder(commitmentValues, order);

		// debt offer must not already be filled.
		require(!debtOfferFilled[id]);

		debtOfferCancelled[id] = true;

		return true;
	}

	function hashCreditorCommitmentForOrder(
		CommitmentValues commitmentValues,
		OrderLibrary.DebtOrder order
	)
		returns (bytes32)
	{
		return keccak256(
			// LTV specific values.
			commitmentValues.maxLTV,
			commitmentValues.principalToken,
			commitmentValues.principalAmount,
			commitmentValues.expirationTimestamp,
			// Order specific values.
			order.creditor,
			order.issuanceVersion,
			order.creditorFee,
			order.underwriter,
			order.underwriterRiskRating,
			order.termsContract,
			order.termsContractParameters,
			order.expirationTimestampInSec,
			order.salt
		);
	}
}
