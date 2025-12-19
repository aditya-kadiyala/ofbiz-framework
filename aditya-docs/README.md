flowchart TB
    %% Client Layer
    UI[React Frontend<br/>Web / Mobile]

    %% Edge
    APIGW[API Gateway<br/>Auth, Rate Limit, Routing]

    %% Platform Services
    Auth[Identity Service<br/>Keycloak / Cognito]
    Config[Config & Secrets]
    Obs[Observability<br/>Logs / Metrics / Traces]
    Events[Event Bus<br/>Kafka or SNS+SQS]

    %% Domain Services
    OrderSvc[Order Service]
    ProductSvc[Product Service]
    InventorySvc[Inventory Service]
    PaymentSvc[Payment Service]

    %% Core
    OFBiz[OFBiz Core<br/>Monolith Container]

    %% Databases
    OFBizDB[(OFBiz DB<br/>PostgreSQL)]
    OrderDB[(Order DB)]
    ProductDB[(Product DB)]
    InventoryDB[(Inventory DB)]

    %% UI Flow
    UI --> APIGW
    APIGW --> Auth

    %% API Routing
    APIGW --> OrderSvc
    APIGW --> ProductSvc
    APIGW --> InventorySvc
    APIGW --> PaymentSvc

    %% Service to Core (Strangler)
    OrderSvc --> OFBiz
    ProductSvc --> OFBiz
    InventorySvc --> OFBiz

    %% Events
    OFBiz --> Events
    OrderSvc --> Events
    InventorySvc --> Events
    PaymentSvc --> Events

    %% Data
    OFBiz --> OFBizDB
    OrderSvc --> OrderDB
    ProductSvc --> ProductDB
    InventorySvc --> InventoryDB

    %% Platform
    Auth -.-> APIGW
    Obs -.-> OrderSvc
    Obs -.-> OFBiz