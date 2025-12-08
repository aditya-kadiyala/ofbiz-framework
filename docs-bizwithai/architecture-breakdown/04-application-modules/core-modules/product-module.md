# Product Module Architecture

**Document Type**: Application Module Documentation  
**Module Classification**: Core Module (Cannot be Disabled)  
**Last Updated**: December 2024

---

## Overview

The Product module manages all product-related functionality in Apache OFBiz, including product definitions, catalogs, categories, pricing, inventory, and product features. It is a **core module that cannot be disabled** because it provides essential e-commerce and inventory management capabilities that other modules depend on.

### Why Product Module Cannot Be Disabled

The Product module is fundamental to OFBiz operations:

1. **Order Dependency**: Orders reference products - no products means no orders
2. **Inventory Management**: Facility and warehouse operations depend on product definitions
3. **Pricing Engine**: All pricing, promotions, and discounts are product-based
4. **Manufacturing**: Production runs require product definitions (raw materials, finished goods)
5. **Accounting**: Cost accounting and revenue recognition tied to products

Disabling the Product module would eliminate core business functionality across multiple domains.

---

## Module Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Product Module Core"
        PCM[Product Catalog Manager]
        PS[Product Services]
        PE[Product Entities]
    end
    
    subgraph "Product Components"
        PD[Product Definitions]
        PC[Product Categories]
        PP[Pricing Engine]
        PF[Product Features]
        PI[Inventory Integration]
    end
    
    subgraph "Dependent Modules"
        OM[Order Module]
        FM[Facility Module]
        MM[Manufacturing Module]
        AM[Accounting Module]
        MKT[Marketing Module]
    end
    
    PCM --> PD
    PCM --> PC
    PCM --> PP
    PCM --> PF
    PCM --> PI
    
    PS --> PE
    
    OM --> PE
    FM --> PE
    MM --> PE
    AM --> PE
    MKT --> PE
    
    style PCM fill:#e1f5ff
    style PE fill:#fff4e1
    style OM fill:#ffe1e1
    style FM fill:#ffe1e1
    style MM fill:#ffe1e1
```

### Component Structure

```mermaid
graph LR
    subgraph "Product Module Structure"
        direction TB
        E[Entity Definitions<br/>entitymodel.xml]
        S[Service Definitions<br/>services.xml]
        W[Screens & Forms<br/>widget/]
        D[Data Files<br/>data/]
        SC[Service Classes<br/>src/]
    end
    
    E --> S
    S --> SC
    W --> S
    D --> E
    
    style E fill:#e1f5ff
    style S fill:#e1ffe1
```

---

## Entity Model

### Core Product Entities

```mermaid
erDiagram
    Product ||--o{ ProductCategory : "belongs to"
    Product ||--o{ ProductPrice : "has"
    Product ||--o{ ProductFeatureAppl : "has"
    Product ||--o{ ProductAssoc : "associated with"
    Product ||--o{ InventoryItem : "tracked by"
    Product ||--|| ProductType : "of type"
    
    ProductCategory ||--o{ ProductCategoryMember : "contains"
    ProductCategoryMember ||--|| Product : "references"
    
    ProductPrice ||--|| ProductPriceType : "of type"
    ProductPrice ||--|| ProductPricePurpose : "for purpose"
    
    ProductFeatureAppl ||--|| ProductFeature : "applies"
    ProductFeature ||--|| ProductFeatureType : "of type"
    
    ProductStore ||--o{ ProductStoreCatalog : "has"
    ProductStoreCatalog ||--|| ProdCatalog : "references"
    ProdCatalog ||--o{ ProdCatalogCategory : "contains"
    ProdCatalogCategory ||--|| ProductCategory : "references"
    
    Product {
        string productId PK
        string productTypeId
        string internalName
        string brandName
        string description
        decimal quantityUomId
        timestamp introductionDate
    }
    
    ProductPrice {
        string productId PK_FK
        string productPriceTypeId PK_FK
        string productPricePurposeId PK_FK
        string currencyUomId PK_FK
        timestamp fromDate PK
        timestamp thruDate
        decimal price
    }
    
    ProductCategory {
        string productCategoryId PK
        string productCategoryTypeId
        string categoryName
        string description
    }
```

### Key Entity Descriptions

<details>
<summary><strong>Product Entity</strong> - Core product definition</summary>

**File**: `applications/product/entitydef/entitymodel.xml`

```xml
<entity entity-name="Product" package-name="org.apache.ofbiz.product.product">
    <field name="productId" type="id"></field>
    <field name="productTypeId" type="id"></field>
    <field name="primaryProductCategoryId" type="id"></field>
    <field name="internalName" type="name"></field>
    <field name="brandName" type="name"></field>
    <field name="comments" type="comment"></field>
    <field name="description" type="description"></field>
    <field name="longDescription" type="very-long"></field>
    <field name="quantityUomId" type="id"></field>
    <field name="introductionDate" type="date-time"></field>
    <field name="salesDiscontinuationDate" type="date-time"></field>
    <prim-key field="productId"/>
</entity>
```

The Product entity represents any sellable or trackable item in the system.

</details>

<details>
<summary><strong>ProductPrice Entity</strong> - Product pricing</summary>

**File**: `applications/product/entitydef/entitymodel.xml`

```xml
<entity entity-name="ProductPrice" package-name="org.apache.ofbiz.product.price">
    <field name="productId" type="id"></field>
    <field name="productPriceTypeId" type="id"></field>
    <field name="productPricePurposeId" type="id"></field>
    <field name="currencyUomId" type="id"></field>
    <field name="productStoreGroupId" type="id"></field>
    <field name="fromDate" type="date-time"></field>
    <field name="thruDate" type="date-time"></field>
    <field name="price" type="currency-amount"></field>
    <prim-key field="productId"/>
    <prim-key field="productPriceTypeId"/>
    <prim-key field="productPricePurposeId"/>
    <prim-key field="currencyUomId"/>
    <prim-key field="productStoreGroupId"/>
    <prim-key field="fromDate"/>
</entity>
```

ProductPrice supports complex pricing scenarios with date ranges, purposes, and store groups.

</details>


---

## Service Architecture

### Product Creation Flow

```mermaid
sequenceDiagram
    participant Client
    participant ProductServices
    participant PriceServices
    participant Delegator
    participant ProductDB
    
    Client->>ProductServices: createProduct(productData)
    ProductServices->>ProductServices: Validate product data
    ProductServices->>Delegator: create(Product)
    Delegator->>ProductDB: INSERT INTO Product
    ProductDB-->>Delegator: Success
    
    ProductServices->>Delegator: create(ProductContent)
    Delegator->>ProductDB: INSERT INTO ProductContent
    
    ProductServices->>PriceServices: createProductPrice(priceData)
    PriceServices->>Delegator: create(ProductPrice)
    Delegator->>ProductDB: INSERT INTO ProductPrice
    
    ProductServices->>ProductServices: Trigger ECA events
    ProductServices-->>Client: {productId, success}
```

### Core Services

<details>
<summary><strong>createProduct Service</strong> - Create new product</summary>

**File**: `applications/product/servicedef/services.xml`

```xml
<service name="createProduct" engine="simple"
         location="component://product/minilang/product/ProductServices.xml" 
         invoke="createProduct" auth="true">
    <description>Create a Product</description>
    <permission-service service-name="productPermissionCheck" main-action="CREATE"/>
    <auto-attributes entity-name="Product" include="nonpk" mode="IN" optional="true"/>
    <attribute name="productId" type="String" mode="OUT" optional="false"/>
</service>
```

Creates a new product with all associated data.

</details>

<details>
<summary><strong>calculateProductPrice Service</strong> - Calculate price</summary>

**File**: `applications/product/servicedef/services.xml`

```xml
<service name="calculateProductPrice" engine="java"
         location="org.apache.ofbiz.product.price.PriceServices" 
         invoke="calculateProductPrice" auth="false">
    <description>Calculate Product Price</description>
    <attribute name="product" type="org.apache.ofbiz.entity.GenericValue" mode="IN" optional="false"/>
    <attribute name="prodCatalogId" type="String" mode="IN" optional="true"/>
    <attribute name="productStoreId" type="String" mode="IN" optional="true"/>
    <attribute name="partyId" type="String" mode="IN" optional="true"/>
    <attribute name="quantity" type="BigDecimal" mode="IN" optional="true"/>
    <attribute name="currencyUomId" type="String" mode="IN" optional="true"/>
    <attribute name="basePrice" type="BigDecimal" mode="OUT" optional="false"/>
    <attribute name="price" type="BigDecimal" mode="OUT" optional="false"/>
    <attribute name="listPrice" type="BigDecimal" mode="OUT" optional="true"/>
</service>
```

Complex pricing calculation considering promotions, discounts, and rules.

</details>

---

## Pricing Engine

### Price Calculation Flow

```mermaid
flowchart TD
    Start([Price Request]) --> GetBase[Get Base Price]
    GetBase --> CheckPromo{Promotions<br/>Active?}
    
    CheckPromo -->|Yes| ApplyPromo[Apply Promotion Rules]
    CheckPromo -->|No| CheckDiscount
    
    ApplyPromo --> CheckDiscount{Volume<br/>Discount?}
    CheckDiscount -->|Yes| ApplyDiscount[Apply Volume Discount]
    CheckDiscount -->|No| CheckCustomer
    
    ApplyDiscount --> CheckCustomer{Customer<br/>Specific?}
    CheckCustomer -->|Yes| ApplyCustomer[Apply Customer Price]
    CheckCustomer -->|No| CheckTax
    
    ApplyCustomer --> CheckTax{Calculate<br/>Tax?}
    CheckTax -->|Yes| AddTax[Add Tax Amount]
    CheckTax -->|No| FinalPrice
    
    AddTax --> FinalPrice[Calculate Final Price]
    FinalPrice --> End([Return Price])
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
    style FinalPrice fill:#fff4e1
```

### Price Types

```mermaid
graph TD
    Price[Product Price] --> List[List Price]
    Price --> Default[Default Price]
    Price --> Wholesale[Wholesale Price]
    Price --> Purchase[Purchase Price]
    Price --> Promo[Promotional Price]
    Price --> Competitive[Competitive Price]
    
    style Price fill:#e1f5ff
    style List fill:#e1ffe1
    style Default fill:#e1ffe1
    style Wholesale fill:#e1ffe1
```

---

## Catalog Management

### Catalog Structure

```mermaid
graph TD
    Store[Product Store] --> Catalog1[Catalog: Electronics]
    Store --> Catalog2[Catalog: Clothing]
    
    Catalog1 --> Cat1[Category: Computers]
    Catalog1 --> Cat2[Category: Phones]
    
    Cat1 --> SubCat1[Subcategory: Laptops]
    Cat1 --> SubCat2[Subcategory: Desktops]
    
    SubCat1 --> Prod1[Product: Laptop A]
    SubCat1 --> Prod2[Product: Laptop B]
    
    style Store fill:#e1f5ff
    style Catalog1 fill:#fff4e1
    style Cat1 fill:#ffe1e1
    style SubCat1 fill:#e1ffe1
```

---

## Module Dependencies

### Incoming Dependencies

```mermaid
graph TD
    Product[Product Module]
    
    Order[Order Module] --> Product
    Facility[Facility Module] --> Product
    Manufacturing[Manufacturing Module] --> Product
    Accounting[Accounting Module] --> Product
    Marketing[Marketing Module] --> Product
    Content[Content Module] --> Product
    
    style Product fill:#e1f5ff
    style Order fill:#ffe1e1
    style Facility fill:#ffe1e1
    style Manufacturing fill:#ffe1e1
```

### Dependency Examples

1. **Order Module**: OrderItem references `productId`
2. **Facility Module**: InventoryItem tracks `productId`
3. **Manufacturing**: ProductionRun produces `productId`
4. **Accounting**: InvoiceItem references `productId` for revenue

---

## Integration Patterns

### External Product Catalog Integration

```mermaid
graph LR
    subgraph "OFBiz Product Module"
        PM[Product Manager]
        PS[Product Services]
        PE[(Product Entities)]
    end
    
    subgraph "Integration Layer"
        SA[Service Adapter]
        DM[Data Mapper]
        SQ[Sync Queue]
    end
    
    subgraph "External Systems"
        PIM[PIM System]
        ERP[External ERP]
        ECOM[E-commerce Platform]
    end
    
    PM --> SA
    SA --> DM
    DM --> SQ
    SQ --> PIM
    SQ --> ERP
    SQ --> ECOM
    
    PIM -.->|Sync Back| SQ
    ERP -.->|Sync Back| SQ
    
    style PM fill:#e1f5ff
    style SA fill:#fff4e1
```

<details>
<summary><strong>Product Import Service</strong></summary>

```java
public static Map<String, Object> importProductFromExternal(DispatchContext dctx, Map<String, ?> context) {
    Delegator delegator = dctx.getDelegator();
    LocalDispatcher dispatcher = dctx.getDispatcher();
    
    String externalProductId = (String) context.get("externalProductId");
    Map<String, Object> productData = (Map<String, Object>) context.get("productData");
    
    try {
        // Check if product exists
        List<GenericValue> existing = delegator.findByAnd("Product", 
            UtilMisc.toMap("externalId", externalProductId), null, false);
        
        if (UtilValidate.isEmpty(existing)) {
            // Create new product
            Map<String, Object> createContext = UtilMisc.toMap(
                "productTypeId", productData.get("productType"),
                "internalName", productData.get("name"),
                "description", productData.get("description"),
                "externalId", externalProductId
            );
            
            Map<String, Object> result = dispatcher.runSync("createProduct", createContext);
            String productId = (String) result.get("productId");
            
            // Create price
            dispatcher.runSync("createProductPrice", UtilMisc.toMap(
                "productId", productId,
                "productPriceTypeId", "DEFAULT_PRICE",
                "productPricePurposeId", "PURCHASE",
                "price", productData.get("price"),
                "currencyUomId", "USD"
            ));
            
            return ServiceUtil.returnSuccess("Product imported: " + productId);
        } else {
            // Update existing product
            GenericValue product = existing.get(0);
            product.set("internalName", productData.get("name"));
            product.set("description", productData.get("description"));
            product.store();
            
            return ServiceUtil.returnSuccess("Product updated: " + product.getString("productId"));
        }
    } catch (Exception e) {
        return ServiceUtil.returnError("Error importing product: " + e.getMessage());
    }
}
```

</details>

---

## Official References

- [Apache OFBiz Product Component](https://cwiki.apache.org/confluence/display/OFBIZ/Product+Component)
- [Product Data Model](https://cwiki.apache.org/confluence/display/OFBIZ/Product+Data+Model)
- [Catalog Management](https://cwiki.apache.org/confluence/display/OFBIZ/Catalog+Management)

---

## Related Documentation

- [Module Architecture Overview](../module-architecture-overview.md)
- [Product Domain Model](../../03-data-architecture/domain-models/product-domain.md)
- [Order Module](order-module.md)
- [Facility Module](../optional-modules/facility-module.md)

---

## Summary

The Product module is essential to OFBiz operations and cannot be disabled. It provides product definitions, catalog management, pricing engine, and inventory integration that all other business modules depend on. While it cannot be disabled, product data can be synchronized with external PIM or ERP systems using adapter patterns.
