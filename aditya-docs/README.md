'''mermaid
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
'''


You are a Principal UI and Platform Architect with deep expertise in
Apache OFBiz internals, IBM Maximo Application Suite (MAS) 9.1, and
enterprise React-based frontend platforms.

Your task is to create a detailed technical specification for
replacing the Freemarker-based UI in Apache OFBiz with a modern
React frontend, following the same UI decoupling strategy used by
IBM Maximo MAS 9.1.

### Current State
- Apache OFBiz uses Freemarker, widgets, and screens
- UI is tightly coupled to OFBiz services and entity engine
- Server-side session management is handled by OFBiz
- PostgreSQL is used as the backend database

### Target State
- All user-facing UI is implemented in React
- React communicates only via versioned REST APIs
- Freemarker, widgets, and screens are fully removed
- OFBiz becomes a headless backend (no UI concerns)
- Authentication and authorization are handled outside OFBiz

### Architectural Principles (Must Follow)
1. React UI never calls OFBiz services directly
2. OFBiz entities are never exposed to the UI
3. APIs are the only contract between UI and backend
4. UI migration follows a strangler pattern (coexistence allowed)
5. Zero functional regression during migration
6. No business logic in the React layer
7. MAS 9.1 UI separation principles must be respected

### Scope of This Specification
Produce a structured specification that includes:

1. High-level UI modernization architecture
2. API gateway and authentication flow
3. React application structure and layering
4. API contract strategy (OpenAPI, versioning)
5. Freemarker freeze and decommission plan
6. Screen-by-screen migration approach
7. Handling of sessions, auth, and RBAC
8. Error handling, logging, and observability
9. Deployment strategy for React on AWS
10. Rollback and coexistence strategy
11. Risks, constraints, and anti-patterns

### Explicit Out of Scope
- Backend microservice extraction
- Database refactoring
- Business logic rewrites
- Performance optimization beyond UI needs

### Deliverables
- Textual architecture diagrams
- Step-by-step UI migration phases
- Clear do’s and don’ts
- Acceptance criteria for fully removing Freemarker

Assume the audience is senior engineers and architects.
Be precise, opinionated, and aligned with MAS 9.1 practices.