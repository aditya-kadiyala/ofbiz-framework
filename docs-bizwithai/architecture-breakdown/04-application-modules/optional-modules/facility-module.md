# Facility Module Architecture

**Document Type**: Application Module Documentation  
**Module Classification**: Optional Module (Can be Replaced)  
**Last Updated**: December 2024

---

## Overview

The Facility module manages warehouses, inventory locations, shipments, and inventory tracking. While critical for physical operations, it is **optional and can be replaced** with external Warehouse Management Systems (WMS) or 3PL (Third-Party Logistics) providers.

### When to Replace Facility Module

1. **External WMS**: Using dedicated systems like Manhattan, HighJump, or SAP EWM
2. **3PL Operations**: Fulfillment handled by third-party logistics providers
3. **Dropshipping**: No inventory management needed
4. **Virtual/Digital Products**: No physical inventory to track

---

## Module Architecture

```mermaid
graph TB
    subgraph "Facility Module"
        FM[Facility Manager]
        FS[Facility Services]
        FE[Facility Entities]
    end
    
    subgraph "Facility Components"
        INV[Inventory Management]
        SHIP[Shipment Management]
        LOC[Location Management]
        PICK[Picking/Packing]
    end
    
    subgraph "Dependencies"
        Product[Product Module]
        Order[Order Module]
        Party[Party Module]
    end
    
    FM --> INV
    FM --> SHIP
    FM --> LOC
    FM --> PICK
    
    FS --> FE
    
    Product --> FE
    Order --> FE
    Party --> FE
    
    style FM fill:#e1f5ff
    style FE fill:#fff4e1
```

---

## Entity Model

```mermaid
erDiagram
    Facility ||--o{ FacilityLocation : "contains"
    Facility ||--o{ InventoryItem : "stores"
    
    InventoryItem ||--|| Product : "tracks"
    InventoryItem ||--|| FacilityLocation : "at location"
    InventoryItem ||--|| InventoryItemType : "of type"
    
    Shipment ||--o{ ShipmentItem : "contains"
    Shipment ||--|| Facility : "from"
    Shipment ||--|| Party : "to"
    ShipmentItem ||--|| OrderItem : "fulfills"
    ShipmentItem ||--|| Product : "ships"
    
    Facility {
        string facilityId PK
        string facilityTypeId
        string facilityName
        string ownerPartyId FK
        string description
    }
    
    InventoryItem {
        string inventoryItemId PK
        string inventoryItemTypeId
        string productId FK
        string facilityId FK
        string locationSeqId FK
        decimal quantityOnHandTotal
        decimal availableToPromiseTotal
    }
    
    Shipment {
        string shipmentId PK
        string shipmentTypeId
        string statusId
        string originFacilityId FK
        string destinationFacilityId FK
        timestamp estimatedShipDate
    }
```

---

## Replacement Strategy

### External WMS Integration

```mermaid
graph LR
    subgraph "OFBiz Core"
        Order[Order Module]
        Product[Product Module]
    end
    
    subgraph "WMS Adapter Layer"
        WA[WMS Adapter]
        DM[Data Mapper]
        SQ[Sync Queue]
    end
    
    subgraph "External WMS"
        Manhattan[Manhattan WMS]
        SAP[SAP EWM]
        ShipStation[ShipStation]
    end
    
    Order -->|Fulfillment Request| WA
    Product -->|Product Data| WA
    
    WA --> DM
    DM --> SQ
    SQ --> Manhattan
    SQ --> SAP
    SQ --> ShipStation
    
    Manhattan -.->|Shipment Status| SQ
    SAP -.->|Inventory Levels| SQ
    ShipStation -.->|Tracking Info| SQ
    
    SQ -.->|Update Order| Order
    
    style WA fill:#fff4e1
    style Manhattan fill:#e1ffe1
```

### Replacement Steps

1. **Implement WMS Adapter**: Create service adapter for external WMS API
2. **Map Fulfillment Requests**: Transform OFBiz orders to WMS format
3. **Sync Inventory Levels**: Pull inventory data from WMS to OFBiz
4. **Track Shipments**: Receive shipment and tracking updates
5. **Maintain References**: Store WMS IDs in OFBiz for reconciliation

<details>
<summary><strong>ShipStation Integration Example</strong></summary>

```java
public class ShipStationAdapter {
    
    public static Map<String, Object> createShipStationOrder(DispatchContext dctx, Map<String, ?> context) {
        Delegator delegator = dctx.getDelegator();
        String orderId = (String) context.get("orderId");
        
        try {
            // Get order data
            GenericValue orderHeader = delegator.findOne("OrderHeader", 
                UtilMisc.toMap("orderId", orderId), false);
            List<GenericValue> orderItems = orderHeader.getRelated("OrderItem", null, null, false);
            
            // Get shipping address
            GenericValue shipToContactMech = getShipToAddress(delegator, orderId);
            GenericValue postalAddress = shipToContactMech.getRelatedOne("PostalAddress", false);
            
            // Map to ShipStation format
            ShipStationOrder ssOrder = new ShipStationOrder();
            ssOrder.setOrderNumber(orderId);
            ssOrder.setOrderDate(orderHeader.getTimestamp("orderDate"));
            ssOrder.setOrderStatus("awaiting_shipment");
            
            // Add shipping address
            ShipStationAddress ssAddress = new ShipStationAddress();
            ssAddress.setName(postalAddress.getString("toName"));
            ssAddress.setStreet1(postalAddress.getString("address1"));
            ssAddress.setCity(postalAddress.getString("city"));
            ssAddress.setState(postalAddress.getString("stateProvinceGeoId"));
            ssAddress.setPostalCode(postalAddress.getString("postalCode"));
            ssAddress.setCountry(postalAddress.getString("countryGeoId"));
            ssOrder.setShipTo(ssAddress);
            
            // Add items
            for (GenericValue item : orderItems) {
                ShipStationItem ssItem = new ShipStationItem();
                ssItem.setSku(item.getString("productId"));
                ssItem.setQuantity(item.getBigDecimal("quantity").intValue());
                ssItem.setUnitPrice(item.getBigDecimal("unitPrice"));
                ssOrder.addItem(ssItem);
            }
            
            // Send to ShipStation
            ShipStationAPI api = new ShipStationAPI();
            String ssOrderId = api.createOrder(ssOrder);
            
            // Store external reference
            orderHeader.set("externalShipmentId", ssOrderId);
            orderHeader.store();
            
            return ServiceUtil.returnSuccess("Order sent to ShipStation: " + ssOrderId);
        } catch (Exception e) {
            return ServiceUtil.returnError("Error sending to ShipStation: " + e.getMessage());
        }
    }
    
    public static Map<String, Object> receiveShipStationWebhook(DispatchContext dctx, Map<String, ?> context) {
        Delegator delegator = dctx.getDelegator();
        
        String eventType = (String) context.get("resource_type");
        Map<String, Object> resourceData = (Map<String, Object>) context.get("resource_url");
        
        try {
            if ("SHIP_NOTIFY".equals(eventType)) {
                String orderNumber = (String) resourceData.get("order_number");
                String trackingNumber = (String) resourceData.get("tracking_number");
                String carrier = (String) resourceData.get("carrier_code");
                
                // Update order in OFBiz
                GenericValue orderHeader = delegator.findOne("OrderHeader", 
                    UtilMisc.toMap("orderId", orderNumber), false);
                
                if (orderHeader != null) {
                    orderHeader.set("trackingNumber", trackingNumber);
                    orderHeader.set("carrierCode", carrier);
                    orderHeader.set("statusId", "ORDER_COMPLETED");
                    orderHeader.store();
                    
                    return ServiceUtil.returnSuccess("Order updated with tracking: " + trackingNumber);
                }
            }
            
            return ServiceUtil.returnSuccess("Webhook processed");
        } catch (Exception e) {
            return ServiceUtil.returnError("Error processing webhook: " + e.getMessage());
        }
    }
}
```

</details>

---

## 3PL Integration Pattern

For third-party logistics providers:

```mermaid
sequenceDiagram
    participant OFBiz
    participant Adapter
    participant 3PL
    participant Customer
    
    OFBiz->>Adapter: Order Approved
    Adapter->>Adapter: Map Order Data
    Adapter->>3PL: Send Fulfillment Request
    3PL-->>Adapter: Fulfillment Accepted
    Adapter-->>OFBiz: Update Order Status
    
    3PL->>3PL: Pick & Pack
    3PL->>3PL: Ship Order
    3PL->>Adapter: Shipment Notification
    Adapter->>OFBiz: Update Tracking Info
    OFBiz->>Customer: Send Tracking Email
    
    3PL->>Customer: Deliver Package
    3PL->>Adapter: Delivery Confirmation
    Adapter->>OFBiz: Mark Order Complete
```

---

## Official References

- [Apache OFBiz Facility Component](https://cwiki.apache.org/confluence/display/OFBIZ/Facility+Component)
- [Shipment Management](https://cwiki.apache.org/confluence/display/OFBIZ/Shipment+Management)

---

## Related Documentation

- [Module Replacement Patterns](../module-replacement-patterns.md)
- [Product Module](../core-modules/product-module.md)
- [Order Module](../core-modules/order-module.md)
- [External Service Adapters](../../05-integration-architecture/external-service-adapters.md)

---

## Summary

The Facility module is optional and can be replaced with external WMS or 3PL providers. Use adapter patterns to send fulfillment requests to external systems and receive shipment status updates. Maintain external references in OFBiz for order tracking and reconciliation.
