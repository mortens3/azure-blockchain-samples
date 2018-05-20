pragma solidity ^0.4.20;

contract WorkbenchBase {
    event WorkbenchContractCreated(string applicationName, string workflowName, address originatingAddress);
    event WorkbenchContractUpdated(string applicationName, string workflowName, string action, address originatingAddress);

    string internal ApplicationName;
    string internal WorkflowName;

    function WorkbenchBase(string applicationName, string workflowName) internal {
        ApplicationName = applicationName;
        WorkflowName = workflowName;
    }

    function ContractCreated() internal {
        WorkbenchContractCreated(ApplicationName, WorkflowName, msg.sender);
    }

    function ContractUpdated(string action) internal {
        WorkbenchContractUpdated(ApplicationName, WorkflowName, action, msg.sender);
    }
}

contract AuctionBlockchain is WorkbenchBase('AuctionBlockchain', 'AuctionBlockchain') {
    //Set of States
    enum StateType { Price, Bid}

    //List of properties
    StateType public  State;
    address public  Seller;
    address public  Buyer;

    string public Price;
    string public Bid;

    // constructor function
    function AuctionBlockchain(string message) public
    {
        Seller = msg.sender;
        Price = message;
        State = StateType.Price;

        // call ContractCreated() to create an instance of this workflow
        ContractCreated();
    }

    // call this function to send a request
    function SendPrice(string priceMessage) public
    {
        if (Seller != msg.sender)
        {
            revert();
        }

        Price = priceMessage;
        State = StateType.Price;

        // call ContractUpdated() to record this action
        ContractUpdated('SendPrice');
    }

    // call this function to send a response
    function SendBid(string bidMessage) public
    {
        Buyer = msg.sender;

        // call ContractUpdated() to record this action
        Bid = bidMessage;
        State = StateType.Bid;
        ContractUpdated('SendResponse');
    }
}