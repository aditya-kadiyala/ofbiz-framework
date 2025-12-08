# Diagram Template Examples

This document provides template examples for different types of diagrams used in the architecture documentation.

---

## 1. Class Diagram (UML)

Use for: Framework components, interfaces, class hierarchies

```mermaid
classDiagram
    class Delegator {
        <<interface>>
        +findOne(entityName, fields, useCache) GenericValue
        +findByAnd(entityName, fields) List~GenericValue~
        +create(value) GenericValue
        +store(value) int
        +remove(value) int
    }
    
    class GenericDelegator {
        -entityEngine EntityEngine
        -cache UtilCache
        +findOne(entityName, fields, useCache) GenericValue
        +findByAnd(entityName, fields) List~GenericValue~
    }
    
    class GenericValue {
        -fields Map
        -modelEntity ModelEntity
        +get(fieldName) Object
        +set(fieldName, value) void
        +store() int
    }
    
    Delegator <|.. GenericDelegator : implements
    GenericDelegator --> GenericValue : creates
    GenericValue --> ModelEntity : uses
```

**Description Template**: This class diagram shows the [component name] architecture. The [Interface] defines the contract for [purpose]. [Implementation class] provides the concrete implementation using [key dependencies]. [Related classes] represent [their role].

---

## 2. Sequence Diagram

Use for: Request flows, service invocation, transaction lifecycles

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant Service as Service Dispatcher
    participant Entity as Entity Engine
    participant DB as Database
    
    Client->>Controller: HTTP Request
    activate Controller
    
    Controller->>Service: Invoke Service
    activate Service
    
    Service->>Service: Validate Input
    Service->>Service: Check Permissions
    
    Service->>Entity: Query Entity
    activate Entity
    
    Entity->>DB: Execute SQL
    activate DB
    DB-->>Entity: Result Set
    deactivate DB
    
    Entity-->>Service: Entity Objects
    deactivate Entity
    
    Service->>Service: Process Business Logic
    
    Service-->>Controller: Service Response
    deactivate Service
    
    Controller-->>Client: HTTP Response
    deactivate Controller
```

**Description Template**: This sequence diagram illustrates the [process name] flow. The process begins when [trigger]. [Component 1] handles [responsibility], then delegates to [Component 2] for [purpose]. [Key steps] occur in sequence, with [important interactions] between components.

---

## 3. Entity-Relationship Diagram (ERD)

Use for: Data models, domain models, entity relationships

```mermaid
erDiagram
    Party ||--o{ PartyRole : has
    Party ||--o{ Person : "is a"
    Party ||--o{ PartyGroup : "is a"
    Party ||--o{ PartyRelationship : "relates to"
    
    Party {
        string partyId PK
        string partyTypeId FK
        string statusId
        datetime createdDate
    }
    
    Person {
        string partyId PK,FK
        string firstName
        string lastName
        date birthDate
    }
    
    PartyGroup {
        string partyId PK,FK
        string groupName
        string groupNameLocal
    }
    
    PartyRole {
        string partyId PK,FK
        string roleTypeId PK,FK
        datetime fromDate
        datetime thruDate
    }
    
    PartyRelationship {
        string partyIdFrom PK,FK
        string partyIdTo PK,FK
        string roleTypeIdFrom PK,FK
        string roleTypeIdTo PK,FK
        datetime fromDate PK
        datetime thruDate
    }
```

**Description Template**: This ERD shows the [domain name] data model. The [main entity] represents [concept]. It has [relationship type] relationships with [related entities]. Key fields include [important fields]. The [specific relationship] enables [business capability].

---

## 4. Component Diagram

Use for: System architecture, module dependencies, component organization

```mermaid
graph TB
    subgraph "Presentation Layer"
        Widget[Widget Framework]
        Webapp[Webapp Framework]
    end
    
    subgraph "Business Logic Layer"
        Service[Service Engine]
        Minilang[Minilang]
    end
    
    subgraph "Data Access Layer"
        Entity[Entity Engine]
        Cache[Cache Manager]
    end
    
    subgraph "Infrastructure Layer"
        Security[Security Framework]
        Base[Base Framework]
    end
    
    Widget --> Service
    Webapp --> Service
    Service --> Entity
    Service --> Security
    Entity --> Cache
    Entity --> Base
    Security --> Base
    
    style Widget fill:#e1f5ff
    style Webapp fill:#e1f5ff
    style Service fill:#fff4e1
    style Entity fill:#f0e1ff
    style Security fill:#ffe1e1
```

**Description Template**: This component diagram shows the [system/module name] architecture organized by layers. The [layer name] contains [components] responsible for [purpose]. Dependencies flow [direction], with [component] depending on [other components] for [functionality].

---

## 5. Flowchart / Process Flow

Use for: Business processes, decision flows, algorithm flows

```mermaid
flowchart TD
    Start([Start: Service Invocation])
    ValidateInput{Input Valid?}
    CheckAuth{Authorized?}
    BeginTx[Begin Transaction]
    ExecuteLogic[Execute Business Logic]
    QueryDB[(Query Database)]
    ProcessData[Process Data]
    CommitTx{Commit OK?}
    Rollback[Rollback Transaction]
    ReturnSuccess[Return Success]
    ReturnError[Return Error]
    End([End])
    
    Start --> ValidateInput
    ValidateInput -->|No| ReturnError
    ValidateInput -->|Yes| CheckAuth
    CheckAuth -->|No| ReturnError
    CheckAuth -->|Yes| BeginTx
    BeginTx --> ExecuteLogic
    ExecuteLogic --> QueryDB
    QueryDB --> ProcessData
    ProcessData --> CommitTx
    CommitTx -->|Success| ReturnSuccess
    CommitTx -->|Failure| Rollback
    Rollback --> ReturnError
    ReturnSuccess --> End
    ReturnError --> End
    
    style Start fill:#90EE90
    style End fill:#FFB6C1
    style ReturnError fill:#FF6B6B
    style ReturnSuccess fill:#4CAF50
```

**Description Template**: This flowchart illustrates the [process name] workflow. The process starts with [initial step], then [key decision points] determine the flow. [Important branches] handle [scenarios]. The process completes with [outcomes].

---

## 6. Deployment Diagram

Use for: Deployment topologies, infrastructure architecture

```mermaid
graph TB
    subgraph "Load Balancer"
        LB[Nginx / HAProxy]
    end
    
    subgraph "Application Tier"
        App1[OFBiz Instance 1<br/>Tomcat]
        App2[OFBiz Instance 2<br/>Tomcat]
        App3[OFBiz Instance 3<br/>Tomcat]
    end
    
    subgraph "Database Tier"
        Master[(PostgreSQL<br/>Master)]
        Replica1[(PostgreSQL<br/>Replica 1)]
        Replica2[(PostgreSQL<br/>Replica 2)]
    end
    
    subgraph "Cache Tier"
        Redis[Redis Cluster]
    end
    
    LB --> App1
    LB --> App2
    LB --> App3
    
    App1 --> Master
    App2 --> Master
    App3 --> Master
    
    App1 --> Replica1
    App2 --> Replica2
    App3 --> Replica1
    
    Master -.->|Replication| Replica1
    Master -.->|Replication| Replica2
    
    App1 --> Redis
    App2 --> Redis
    App3 --> Redis
    
    style LB fill:#4CAF50
    style Master fill:#2196F3
    style Replica1 fill:#64B5F6
    style Replica2 fill:#64B5F6
```

**Description Template**: This deployment diagram shows the [deployment type] topology. [Load balancer] distributes traffic across [number] application instances. The [database tier] uses [replication strategy] for [purpose]. [Cache tier] provides [caching strategy].

---

## 7. State Diagram

Use for: Entity lifecycles, workflow states, status transitions

```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Approved : approve()
    Created --> Cancelled : cancel()
    Approved --> InProgress : start()
    InProgress --> Completed : complete()
    InProgress --> OnHold : hold()
    OnHold --> InProgress : resume()
    InProgress --> Cancelled : cancel()
    Completed --> [*]
    Cancelled --> [*]
    
    note right of Created
        Initial state after
        entity creation
    end note
    
    note right of Completed
        Final state -
        no further transitions
    end note
```

**Description Template**: This state diagram shows the lifecycle of [entity/process name]. The entity begins in [initial state] and can transition through [key states]. [Specific transitions] occur when [conditions/events]. Terminal states are [final states].

---

## Diagram Best Practices

### 1. Clarity
- Keep diagrams focused on one concept
- Use consistent naming conventions
- Label all relationships and flows
- Include legends when needed

### 2. Completeness
- Show all key components
- Include important relationships
- Label cardinality for ERDs
- Show direction of dependencies

### 3. Readability
- Use appropriate diagram type for the concept
- Limit complexity (split into multiple diagrams if needed)
- Use colors to group related elements
- Add notes for clarification

### 4. Consistency
- Use same notation across all documents
- Maintain consistent component names
- Follow OFBiz naming conventions
- Use standard Mermaid syntax

### 5. Description
- Always include a description after each diagram
- Explain what the diagram shows
- Highlight key elements and relationships
- Reference the diagram in the text

---

## Mermaid Syntax Quick Reference

**Class Diagram**:
- `class ClassName` - Define a class
- `<<interface>>` - Mark as interface
- `+method()` - Public method
- `-field` - Private field
- `<|--` - Inheritance
- `-->` - Association
- `*--` - Composition

**Sequence Diagram**:
- `participant Name` - Define participant
- `->>` - Synchronous message
- `-->>` - Return message
- `activate/deactivate` - Lifeline
- `Note right of` - Add notes

**ER Diagram**:
- `||--o{` - One to many
- `||--||` - One to one
- `}o--o{` - Many to many
- `PK` - Primary key
- `FK` - Foreign key

**Flowchart**:
- `[Text]` - Rectangle
- `{Text}` - Diamond (decision)
- `([Text])` - Rounded (start/end)
- `[(Text)]` - Cylinder (database)
- `-->` - Arrow

---

**For More Examples**: See [Mermaid Documentation](https://mermaid-js.github.io/)
