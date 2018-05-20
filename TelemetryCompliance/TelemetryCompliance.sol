pragma solidity ^0.4.10; 

contract LexingtonBase { 
    event LexingtonContractCreated(string contractType, address originatingAddress); 
    event LexingtonContractUpdated(string contractType, string action, address originatingAddress); 
     
    string ContractType; 
 
    function LexingtonBase(string contractType) { 
        ContractType = contractType; 
    } 
 
    function ContractCreated() { 
        LexingtonContractCreated(ContractType, msg.sender); 
    } 
 
    function ContractUpdated(string action) { 
        LexingtonContractUpdated(ContractType, action, msg.sender); 
    } 
} 

contract TelemetryCompliance is LexingtonBase('TelemetryCompliance') 
{ 
     enum PackageState { 
        Creating, 
        Created, 
        TransitionRequestPending, 
        InTransit, 
        FinalDelivery, 
        Completed, 
        OutOfCompliance 
    } 

    PackageState public State;

    address public InitiatingCounterparty; 
    address public Counterparty; 
    address public PreviousCounterparty; 
    address public RequestedCounterparty; 
    address public Device; 
    address public SupplyChainOwner; 
    address public SupplyChainObserver; 

    int public MinHumidity; 
    int public MaxHumidity; 
    int public MinTemperature; 
    int public MaxTemperature; 
    int public LastHumidity; 
    int public LastTemperature; 
    uint public LastSensorUpdateTimestamp; 

    enum SensorType { None, Humidity, Temperature } 
    bool public ComplianceStatus; 
    string public ComplianceDetail; 
    SensorType public ComplianceSensorType; 
    int public ComplianceSensorReading; 

     function TelemetryCompliance(address device, address supplyChainOwner, address supplyChainObserver, int minHumidity, int maxHumidity, int minTemperature, int maxTemperature)  
    { 
        ComplianceStatus = true; 
        ComplianceSensorReading = -1; 
        InitiatingCounterparty = msg.sender; 
        Counterparty = InitiatingCounterparty; 
        Device = device; 
        SupplyChainOwner = supplyChainOwner; 
        SupplyChainObserver = supplyChainObserver; 
        MinHumidity = minHumidity; 
        MaxHumidity = maxHumidity; 
        MinTemperature = minTemperature; 
        MaxTemperature = maxTemperature; 
        State = PackageState.Created; 
        ContractCreated(); 
    } 

    function IngestTelemetry(int humidity, int temperature, uint timestamp) 
    { 
        if (Device != msg.sender || State == PackageState.OutOfCompliance || State == PackageState.Completed) 
        { 
            revert(); 
        } 
         
        LastHumidity = humidity; 
        LastTemperature = temperature; 
        LastSensorUpdateTimestamp = timestamp; 
         
        if (humidity > MaxHumidity || humidity < MinHumidity) 
        { 
            ComplianceSensorType = SensorType.Humidity; 
            ComplianceSensorReading = humidity; 
            ComplianceDetail = 'Humidity value out of range.'; 
            ComplianceStatus = false; 
        } 
        else if (temperature > MaxTemperature || temperature < MinTemperature) 
        { 
            ComplianceSensorType = SensorType.Temperature; 
            ComplianceSensorReading = temperature; 
            ComplianceDetail = 'Temperature value out of range.'; 
            ComplianceStatus = false; 
        } 
 
        if (ComplianceStatus == false) 
        { 
            State = PackageState.OutOfCompliance; 
          /*When updating state */ 
            ContractUpdated("IngestTelemetry");     
        } 
    } 

    function RequestTransferResponsibility( address newCounterparty ) 
    { 
        if (Counterparty != msg.sender || (State != PackageState.Created && State != PackageState.InTransit) || newCounterparty == Device || newCounterparty == SupplyChainObserver) 
        { 
            revert(); 
        } 
        RequestedCounterparty = newCounterparty; 
        State = PackageState.TransitionRequestPending; 
        /*When updating state */ 
        ContractUpdated("RequestTransferResponsibility"); 
    } 

     function AcceptTransferResponsibility() 
    { 
        if (RequestedCounterparty != msg.sender || State != PackageState.TransitionRequestPending) 
        { 
            revert(); 
        } 
 
        PreviousCounterparty = Counterparty; 
        Counterparty = RequestedCounterparty; 
        RequestedCounterparty = 0x0; 
        State = PackageState.InTransit; 
        /*When updating state */ 
        ContractUpdated("AcceptTransferResponsibility"); 
    } 

    function TakeFinalDelivery() 
    { 
        if (Counterparty != msg.sender || State != PackageState.InTransit) 
        { 
            revert(); 
        } 
 
        State = PackageState.FinalDelivery; 
        /*When updating state */ 
        ContractUpdated("TakeFinalDelivery");     
    } 

     function Complete() 
    { 
        if (SupplyChainOwner != msg.sender || State != PackageState.FinalDelivery) 
        { 
            revert(); 
        } 
 
        PreviousCounterparty = Counterparty; 
        Counterparty = 0x0; 
        State = PackageState.Completed; 
        /*When updating state */ 
        ContractUpdated("Complete"); 
    } 

    
} 