pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI_0.5.sol";

contract RandomExample is usingProvable {

    uint256 constant MAX_INT_FROM_BYTE = 2; // set number of random values to choose from
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1; //how many bytes of numbers to use

    event LogNewProvableQuery(string description);
    event generatedRandomNumber(uint256 randomNumber);

    constructor()
        public
    {
        provable_setProof(proofType_Ledger);
        update();
    }

// This function is called back when the random number is event is emitted from the oracle.
    function __callback( bytes32 _queryId, string memory _result, bytes memory _proof )
        public
    {
        require(msg.sender == provable_cbAddress());

        if (provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
             // the proof verification has failed! Handle this case

        } else {
             // The proof verifiction has passed!
            uint256 ceiling = (MAX_INT_FROM_BYTE ** NUM_RANDOM_BYTES_REQUESTED) - 1;
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % ceiling;
            emit generatedRandomNumber(randomNumber);
        }
    }

// This function is calling the random number
    function update()
        payable
        public
    {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        bytes32 QueryID;
        QueryID = provable_newRandomDSQuery( QUERY_EXECUTION_DELAY, NUM_RANDOM_BYTES_REQUESTED, GAS_FOR_CALLBACK );
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
    }
}
