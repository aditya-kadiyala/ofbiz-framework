# Enterprise Integration Patterns in OFBiz

**Document Type**: Integration Architecture  
**Category**: Integration Patterns  
**Last Updated**: December 2024

---

## Overview

This document describes how Enterprise Integration Patterns (EIP) from Gregor Hohpe and Bobby Woolf are implemented and can be applied in Apache OFBiz for system integration. OFBiz naturally implements many of these patterns through its service engine, ECA/SECA mechanisms, and entity engine.

---

## Message Construction Patterns

### Message Pattern

```mermaid
graph LR
    Sender[Sender System] -->|Message| Channel[Message Channel]
    Channel -->|Message| Receiver[Receiver System]
    
    Message[Message Structure:<br/>Header + Body]
    
    style Message fill:#e1f5ff
```

**OFBiz Implementation**: Service context maps serve as messages

```java
// Service call as message
Map<String, Object> message = UtilMisc.toMap(
    "orderId", "10000",
    "statusId", "ORDER_APPROVED",
    "timestamp", UtilDateTime.nowTimestamp()
);

dispatcher.runAsync("processOrder", message);
```

### Command Message Pattern

```mermaid
sequenceDiagram
    participant Sender
    participant ServiceEngine
    participant Receiver
    
    Sender->>ServiceEngine: Command Message<br/>(createOrder)
    ServiceEngine->>Receiver: Invoke Service
    Receiver->>Receiver: Execute Command
    Receiver-->>ServiceEngine: Result
    ServiceEngine-->>Sender: Acknowledgment
```

**OFBiz Implementation**: Service invocations are command messages

<details>
<summary><strong>Command Message Example</strong></summary>

```xml
<!-- Service definition as command -->
<service name="createOrder" engine="java"
         location="org.apache.ofbiz.order.order.OrderServices" 
         invoke="createOrder">
    <description>Command: Create Order</description>
    <attribute name="orderTypeId" type="String" mode="IN"/>
    <attribute name="orderItems" type="List" mode="IN"/>
    <attribute name="orderId" type="String" mode="OUT"/>
</service>
```

```java
// Sending command message
Map<String, Object> command = UtilMisc.toMap(
    "orderTypeId", "SALES_ORDER",
    "orderItems", orderItemsList
);

Map<String, Object> result = dispatcher.runSync("createOrder", command);
String orderId = (String) result.get("orderId");
```

</details>

### Event Message Pattern

```mermaid
graph TB
    Event[Event Occurs] -->|Trigger| ECA[ECA Rule]
    ECA -->|Publish| EventMessage[Event Message]
    EventMessage -->|Notify| Subscriber1[Subscriber 1]
    EventMessage -->|Notify| Subscriber2[Subscriber 2]
    EventMessage -->|Notify| Subscriber3[Subscriber 3]
    
    style Event fill:#e1f5ff
    style EventMessage fill:#fff4e1
```

**OFBiz Implementation**: ECA/SECA rules publish event messages

<details>
<summary><strong>Event Message Example</strong></summary>

```xml
<!-- ECA rule publishes event message -->
<eca entity="OrderHeader" operation="store" event="return">
    <condition field-name="statusId" operator="equals" value="ORDER_APPROVED"/>
    <action service="sendOrderApprovedNotification" mode="async"/>
    <action service="reserveInventory" mode="async"/>
    <action service="authorizePayment" mode="async"/>
</eca>
```

</details>

---

## Message Routing Patterns

### Content-Based Router

```mermaid
flowchart TD
    Input[Incoming Message] --> Router{Content-Based<br/>Router}
    Router -->|orderTypeId=SALES_ORDER| SalesChannel[Sales Order Channel]
    Router -->|orderTypeId=PURCHASE_ORDER| PurchaseChannel[Purchase Order Channel]
    Router -->|orderTypeId=RETURN_ORDER| ReturnChannel[Return Order Channel]
    
    SalesChannel --> SalesProcessor[Sales Order Processor]
    PurchaseChannel --> PurchaseProcessor[Purchase Order Processor]
    ReturnChannel --> ReturnProcessor[Return Order Processor]
    
    style Router fill:#e1f5ff
```

**OFBiz Implementation**: Service routing based on context

<details>
<summary><strong>Content-Based Router Service</strong></summary>

```java
public static Map<String, Object> routeOrder(DispatchContext dctx, Map<String, ?> context) {
    LocalDispatcher dispatcher = dctx.getDispatcher();
    String orderTypeId = (String) context.get("orderTypeId");
    
    try {
        String targetService;
        
        // Content-based routing
        switch (orderTypeId) {
            case "SALES_ORDER":
                targetService = "processSalesOrder";
                break;
            case "PURCHASE_ORDER":
                targetService = "processPurchaseOrder";
                break;
            case "RETURN_ORDER":
                targetService = "processReturnOrder";
                break;
            default:
                return ServiceUtil.returnError("Unknown order type: " + orderTypeId);
        }
        
        // Route to appropriate service
        return dispatcher.runSync(targetService, context);
        
    } catch (GenericServiceException e) {
        return ServiceUtil.returnError("Routing error: " + e.getMessage());
    }
}
```

</details>

### Message Filter

```mermaid
flowchart LR
    Input[All Messages] --> Filter{Message<br/>Filter}
    Filter -->|Pass| ValidMessages[Valid Messages]
    Filter -->|Discard| InvalidMessages[Invalid Messages]
    
    ValidMessages --> Processor[Message Processor]
    
    style Filter fill:#e1f5ff
    style InvalidMessages fill:#ffe1e1
```

**OFBiz Implementation**: ECA conditions act as filters

```xml
<!-- Message filter using ECA conditions -->
<eca entity="OrderHeader" operation="create" event="return">
    <!-- Filter: Only process orders above $100 -->
    <condition field-name="grandTotal" operator="greater" value="100.00"/>
    <action service="processHighValueOrder" mode="async"/>
</eca>

<eca entity="OrderHeader" operation="create" event="return">
    <!-- Filter: Only process approved orders -->
    <condition field-name="statusId" operator="equals" value="ORDER_APPROVED"/>
    <action service="fulfillOrder" mode="async"/>
</eca>
```

### Recipient List

```mermaid
graph TB
    Message[Incoming Message] --> RecipientList[Recipient List<br/>Determiner]
    RecipientList --> R1[Recipient 1]
    RecipientList --> R2[Recipient 2]
    RecipientList --> R3[Recipient 3]
    RecipientList --> R4[Recipient 4]
    
    style RecipientList fill:#e1f5ff
```

**OFBiz Implementation**: Multiple ECA actions or service groups

```xml
<!-- Recipient list pattern -->
<eca entity="OrderHeader" operation="create" event="return">
    <condition field-name="statusId" operator="equals" value="ORDER_CREATED"/>
    <!-- Send to multiple recipients -->
    <action service="notifyCustomer" mode="async"/>
    <action service="notifySalesTeam" mode="async"/>
    <action service="notifyWarehouse" mode="async"/>
    <action service="notifyAccounting" mode="async"/>
</eca>
```

---

## Message Transformation Patterns

### Message Translator

```mermaid
graph LR
    SourceFormat[Source Format] --> Translator[Message<br/>Translator]
    Translator --> TargetFormat[Target Format]
    
    SourceFormat2[OFBiz Format] --> Translator2[Translator<br/>Service]
    Translator2 --> ExternalFormat[External System<br/>Format]
    
    style Translator fill:#e1f5ff
    style Translator2 fill:#e1f5ff
```

**OFBiz Implementation**: Transformation services

<details>
<summary><strong>Message Translator Service</strong></summary>

```java
public static Map<String, Object> translateOrderToExternalFormat(DispatchContext dctx, Map<String, ?> context) {
    Delegator delegator = dctx.getDelegator();
    String orderId = (String) context.get("orderId");
    
    try {
        // Get OFBiz order data
        GenericValue orderHeader = delegator.findOne("OrderHeader", 
            UtilMisc.toMap("orderId", orderId), false);
        List<GenericValue> orderItems = orderHeader.getRelated("OrderItem", null, null, false);
        
        // Translate to external format
        Map<String, Object> externalOrder = new HashMap<>();
        externalOrder.put("external_order_id", orderId);
        externalOrder.put("order_date", orderHeader.getTimestamp("orderDate").toString());
        externalOrder.put("total_amount", orderHeader.getBigDecimal("grandTotal"));
        externalOrder.put("currency", orderHeader.getString("currencyUom"));
        
        List<Map<String, Object>> externalItems = new ArrayList<>();
        for (GenericValue item : orderItems) {
            Map<String, Object> externalItem = new HashMap<>();
            externalItem.put("sku", item.getString("productId"));
            externalItem.put("qty", item.getBigDecimal("quantity"));
            externalItem.put("price", item.getBigDecimal("unitPrice"));
            externalItems.add(externalItem);
        }
        externalOrder.put("line_items", externalItems);
        
        Map<String, Object> result = ServiceUtil.returnSuccess();
        result.put("externalOrder", externalOrder);
        return result;
        
    } catch (GenericEntityException e) {
        return ServiceUtil.returnError("Translation error: " + e.getMessage());
    }
}
```

</details>

### Envelope Wrapper

```mermaid
graph LR
    OriginalMessage[Original<br/>Message] --> Wrapper[Envelope<br/>Wrapper]
    Wrapper --> EnvelopedMessage[Enveloped<br/>Message]
    
    EnvelopedMessage --> Unwrapper[Envelope<br/>Unwrapper]
    Unwrapper --> OriginalMessage2[Original<br/>Message]
    
    style Wrapper fill:#e1f5ff
    style Unwrapper fill:#e1f5ff
```

**OFBiz Implementation**: Service context wrapping

```java
// Wrap message with envelope
public static Map<String, Object> wrapMessageWithEnvelope(DispatchContext dctx, Map<String, ?> context) {
    Map<String, Object> payload = (Map<String, Object>) context.get("payload");
    
    // Create envelope
    Map<String, Object> envelope = new HashMap<>();
    envelope.put("messageId", UUID.randomUUID().toString());
    envelope.put("timestamp", UtilDateTime.nowTimestamp());
    envelope.put("source", "ofbiz");
    envelope.put("version", "1.0");
    envelope.put("payload", payload);
    
    Map<String, Object> result = ServiceUtil.returnSuccess();
    result.put("envelope", envelope);
    return result;
}
```

---

## Message Endpoint Patterns

### Polling Consumer

```mermaid
sequenceDiagram
    participant Consumer
    participant MessageQueue
    participant Processor
    
    loop Every N seconds
        Consumer->>MessageQueue: Poll for messages
        alt Messages available
            MessageQueue-->>Consumer: Return messages
            Consumer->>Processor: Process messages
        else No messages
            MessageQueue-->>Consumer: Empty
        end
    end
```

**OFBiz Implementation**: Scheduled jobs poll for work

```xml
<!-- Polling consumer as scheduled job -->
<service name="pollExternalOrderQueue" engine="java"
         location="com.company.integration.PollingServices" 
         invoke="pollExternalOrderQueue">
    <description>Poll external system for new orders</description>
</service>

<!-- Schedule polling -->
<job-sandbox job-id="POLL_ORDERS" job-name="Poll External Orders">
    <run-time>
        <frequency frequency-type="MINUTELY" interval-number="5"/>
    </run-time>
    <service service-name="pollExternalOrderQueue"/>
</job-sandbox>
```

### Event-Driven Consumer

```mermaid
sequenceDiagram
    participant EventSource
    participant Consumer
    participant Processor
    
    EventSource->>Consumer: Push Event
    Consumer->>Processor: Process Event
    Processor-->>Consumer: Result
    Consumer-->>EventSource: Acknowledgment
```

**OFBiz Implementation**: ECA rules as event-driven consumers

```xml
<!-- Event-driven consumer -->
<eca entity="OrderHeader" operation="create" event="return">
    <action service="processNewOrder" mode="async"/>
</eca>
```

---

## System Management Patterns

### Control Bus

```mermaid
graph TB
    ControlBus[Control Bus] -->|Start/Stop| Service1[Service 1]
    ControlBus -->|Configure| Service2[Service 2]
    ControlBus -->|Monitor| Service3[Service 3]
    
    Service1 -.->|Status| ControlBus
    Service2 -.->|Metrics| ControlBus
    Service3 -.->|Health| ControlBus
    
    style ControlBus fill:#e1f5ff
```

**OFBiz Implementation**: Service management through webtools

- Service engine provides control bus functionality
- Services can be enabled/disabled dynamically
- Service statistics and monitoring available

### Wire Tap

```mermaid
graph LR
    Source[Message Source] --> MainChannel[Main Channel]
    MainChannel --> Destination[Destination]
    MainChannel -.->|Copy| WireTap[Wire Tap]
    WireTap -.->|Log/Monitor| Monitor[Monitoring System]
    
    style WireTap fill:#e1f5ff
```

**OFBiz Implementation**: ECA rules for auditing

```xml
<!-- Wire tap for auditing -->
<eca entity="OrderHeader" operation="create-store" event="return">
    <!-- Main processing continues -->
    <action service="auditOrderChange" mode="async"/>
    <action service="logOrderEvent" mode="async"/>
</eca>
```

---

## Official References

- [Enterprise Integration Patterns Book](https://www.enterpriseintegrationpatterns.com/)
- [Apache Camel EIP](https://camel.apache.org/components/latest/eips/enterprise-integration-patterns.html)

---

## Related Documentation

- [ECA/SECA Overview](../../02-framework-core/event-driven-architecture/eca-seca-overview.md)
- [Service Engine Overview](../../02-framework-core/service-engine/overview.md)
- [Event-Driven Integration](event-driven-integration.md)
- [External Service Adapters](external-service-adapters.md)

---

## Summary

OFBiz naturally implements many Enterprise Integration Patterns through its service engine and ECA/SECA mechanisms. The service engine provides message construction and routing, ECA rules enable event-driven processing, and the entity engine supports data transformation. Understanding these patterns helps design robust integrations with external systems.
