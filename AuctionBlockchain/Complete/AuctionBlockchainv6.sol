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

contract AuctionBlockchainv6 is WorkbenchBase("AuctionBlockchainv6", "AuctionBlockchainv6") {
    //Set of States
    enum StateType { Sell, Bid, Sold}

    //List of properties
    StateType public  State;
    address public  Seller;
    address public  Buyer;
    string public ItemToSell;
    int public Price;
    int public Bid;

    // constructor function
    function AuctionBlockchainv6(string itemtosell, int message) public
    {
        Seller = msg.sender;
        Price = message;
        State = StateType.Sell;
        ItemToSell = itemtosell;

        // call ContractCreated() to create an instance of this workflow
        ContractCreated();
    }

    // call this function to send a request
    function SendPrice(int message) public
    {
        if (Seller != msg.sender)
        {
            revert();
        }

        Price = message;
        State = StateType.Sell;

        // call ContractUpdated() to record this action
        ContractUpdated("SendPrice");
    }

    // call this function to send a response
    function SendBid(int message) public
    {
        Buyer = msg.sender;

        // call ContractUpdated() to record this action
        Bid = message;
        State = StateType.Bid;
        if (Bid > Price)
            SendSold(message);
        else
            ContractUpdated("SendBid");
    }

     // call this function to send a response
    function SendSold(int message) public
    {
        Buyer = msg.sender;

        // call ContractUpdated() to record this action
        Bid = message;
        State = StateType.Sold;
        ContractUpdated("SendSold");
    }
}