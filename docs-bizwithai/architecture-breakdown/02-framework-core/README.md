# 02. Framework Core

## Overview

This section provides deep technical documentation of OFBiz framework components - the foundation upon which all business applications are built. These components provide data access, business logic orchestration, UI rendering, security, and event-driven capabilities.

## Contents

### Entity Engine (ORM Layer)
1. **[Overview](entity-engine/overview.md)** - Entity Engine architecture, Delegator interface, capabilities
2. **[Class Structure](entity-engine/class-structure.md)** - UML diagrams, key classes (Delegator, GenericValue, ModelEntity)
3. **[Query Engine](entity-engine/query-engine.md)** - EntityQuery API, query optimization, caching integration
4. **[Transaction Management](entity-engine/transaction-management.md)** - Transaction lifecycle, isolation levels, distributed transactions
5. **[Replacement Strategies](entity-engine/replacement-strategies.md)** - Integrating Hibernate, JPA, or other ORMs

### Service Engine
1. **[Overview](service-engine/overview.md)** - Service Engine architecture, Dispatcher interface, execution modes
2. **[Class Structure](service-engine/class-structure.md)** - UML diagrams, key classes (Dispatcher, ModelService, ServiceUtil)
3. **[Service Invocation](service-engine/service-invocation.md)** - Sync/async flows, service chaining, permission checking
4. **[Transaction Handling](service-engine/transaction-handling.md)** - Transaction propagation, rollback, error handling
5. **[Replacement Strategies](service-engine/replacement-strategies.md)** - Integrating Spring Services or other orchestration frameworks

### Widget Framework
1. **[Overview](widget-framework/overview.md)** - Screen, Form, Menu, Tree widgets and rendering engine
2. **[Rendering Pipeline](widget-framework/rendering-pipeline.md)** - Widget processing flow, FreeMarker integration
3. **[Form Processing](widget-framework/form-processing.md)** - Form submission, validation, event handling
4. **[Replacement Strategies](widget-framework/replacement-strategies.md)** - Integrating React, Vue, Angular, or other frontend frameworks

### Security Framework
1. **[Overview](security-framework/overview.md)** - Authentication and authorization architecture
2. **[Replacement Strategies](security-framework/replacement-strategies.md)** - Integrating OAuth2, SAML, enterprise SSO

### Webapp Framework
1. **[Overview](webapp-framework/overview.md)** - Webapp architecture, controller, request mapping
2. **[Request Pipeline](webapp-framework/request-pipeline.md)** - Complete HTTP request-to-response sequence

### Event-Driven Architecture
1. **[ECA/SECA Overview](event-driven-architecture/eca-seca-overview.md)** - Why ECA/SECA is essential for decoupling
2. **[Alternative Event Systems](event-driven-architecture/alternative-event-systems.md)** - Integrating Kafka, RabbitMQ, Spring Events

## Key Concepts

- **Entity Engine**: OFBiz's ORM layer providing database abstraction, caching, and transaction management
- **Service Engine**: Business logic orchestration with support for sync/async execution, transactions, and permissions
- **Widget Framework**: XML-based UI definition system that renders to HTML via FreeMarker templates
- **Security Framework**: Authentication, authorization, and permission checking integrated throughout the stack
- **Webapp Framework**: Request routing, event handling, and response generation
- **ECA/SECA**: Entity/Service Condition Actions - event-driven mechanisms for decoupling business logic

## Who Should Read This Section?

- **Developers** building customizations or extensions
- **Architects** understanding framework capabilities and limitations
- **Integration Specialists** replacing or extending framework components
- **Technical Leads** making technology decisions
- **Performance Engineers** optimizing framework usage

## Prerequisites

Before reading this section, you should understand:
- [System Overview](../01-system-overview/README.md) - High-level architecture and modular design
- [Modular Architecture](../01-system-overview/modular-architecture.md) - Component organization
- Basic Java programming and enterprise application concepts

## Related Sections

- [Data Architecture](../03-data-architecture/README.md) - Entity models and domain ERDs
- [Application Modules](../04-application-modules/README.md) - How business modules use framework components
- [Runtime Architecture](../06-runtime-architecture/README.md) - Bootstrap, request lifecycle, threading
- [Extension Points](../08-extension-points/README.md) - Safe customization patterns

## Learning Path

**For Developers**:
1. Start with [Entity Engine Overview](entity-engine/overview.md) to understand data access
2. Read [Service Engine Overview](service-engine/overview.md) to understand business logic orchestration
3. Study [Widget Framework Overview](widget-framework/overview.md) for UI rendering
4. Review [Security Framework Overview](security-framework/overview.md) for authentication/authorization
5. Explore [ECA/SECA Overview](event-driven-architecture/eca-seca-overview.md) for event-driven patterns

**For Architects Evaluating Replacement**:
1. Review each component's overview to understand current architecture
2. Read replacement strategies for components you want to replace
3. Study [Module Replacement Patterns](../04-application-modules/module-replacement-patterns.md)
4. Review [Integration Architecture](../05-integration-architecture/README.md) for integration patterns

**For Performance Engineers**:
1. Focus on [Entity Engine Query Engine](entity-engine/query-engine.md) for query optimization
2. Study [Transaction Management](entity-engine/transaction-management.md) for transaction tuning
3. Review [Caching Strategy](../03-data-architecture/caching-strategy.md) for cache optimization
4. Read [Thread Model](../06-runtime-architecture/thread-model.md) for concurrency tuning

## Important Notes

### Framework Component Replacement

- **Entity Engine**: Can be replaced with Hibernate or JPA, but requires significant adapter development
- **Service Engine**: Can be replaced with Spring Services or other orchestration frameworks
- **Widget Framework**: Can be replaced with modern frontend frameworks (React, Vue, Angular)
- **Security Framework**: Can be integrated with OAuth2, SAML, or enterprise SSO
- **ECA/SECA**: Essential for decoupling - can be replaced but not disabled without breaking module interactions

### Code References

All documents in this section include references to actual source code in the `framework/` directory. Code references are in collapsible blocks to maintain readability.

---

**Up**: [Master Index](../00-INDEX.md)  
**Previous**: [System Overview](../01-system-overview/README.md)  
**Next**: [Data Architecture](../03-data-architecture/README.md)
