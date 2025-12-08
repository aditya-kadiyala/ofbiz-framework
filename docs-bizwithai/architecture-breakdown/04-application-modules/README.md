# 04. Application Modules

## Overview

This section documents OFBiz business application modules, their architecture, isolation techniques, and replacement patterns. It distinguishes between core modules (Party, Product, Order) that cannot be disabled and optional modules (Accounting, Manufacturing, Marketing) that can be disabled or replaced with external systems.

## Contents

### Module Architecture
1. **[Module Architecture Overview](module-architecture-overview.md)** - Core vs optional modules, module interaction patterns

### Core Modules (Cannot be Disabled)
2. **[Party Module](core-modules/party-module.md)** - Party management architecture, why it cannot be disabled
3. **[Product Module](core-modules/product-module.md)** - Product catalog architecture, why it cannot be disabled
4. **[Order Module](core-modules/order-module.md)** - Order processing architecture, why it cannot be disabled

### Optional Modules (Can be Disabled or Replaced)
5. **[Accounting Module](optional-modules/accounting-module.md)** - Financial management, how to replace with external systems
6. **[Manufacturing Module](optional-modules/manufacturing-module.md)** - MRP and production, how to disable
7. **[Marketing Module](optional-modules/marketing-module.md)** - Campaigns and tracking, how to disable

### Module Management
8. **[Module Isolation Techniques](module-isolation-techniques.md)** - Techniques for toggling module influence, dependency analysis
9. **[Module Replacement Patterns](module-replacement-patterns.md)** - Service adapters, data synchronization, interface contracts

### External Integration Examples
10. **[QuickBooks Integration](external-integration-examples/quickbooks-integration.md)** - Replace accounting module with QuickBooks
11. **[Salesforce Integration](external-integration-examples/salesforce-integration.md)** - Hybrid party management with Salesforce
12. **[Stripe Integration](external-integration-examples/stripe-integration.md)** - Payment processing with Stripe

## Key Concepts

- **Core Modules**: Party, Product, and Order modules are fundamental and cannot be disabled - they're used throughout the system
- **Optional Modules**: Accounting, Manufacturing, Marketing, and other modules can be disabled or replaced
- **Module Isolation**: Techniques for minimizing dependencies and toggling module influence
- **Service Adapters**: Pattern for integrating external systems while maintaining OFBiz interfaces
- **Hybrid Architecture**: Using OFBiz for some functions and external systems for others
- **ECA/SECA Decoupling**: Event-driven mechanisms that enable module isolation

## Who Should Read This Section?

- **Architects** designing solutions that replace OFBiz modules with external systems
- **Integration Specialists** connecting OFBiz with QuickBooks, Salesforce, or other systems
- **Developers** understanding module boundaries and dependencies
- **Technical Decision Makers** evaluating which modules to use vs replace
- **Solution Designers** planning hybrid architectures

## Prerequisites

Before reading this section, you should understand:
- [System Overview](../01-system-overview/README.md) - Modular architecture concepts
- [Framework Core](../02-framework-core/README.md) - Entity Engine, Service Engine, ECA/SECA
- [Data Architecture](../03-data-architecture/README.md) - Domain models (Party, Product, Order, Accounting)

## Related Sections

- [Data Architecture](../03-data-architecture/README.md) - Domain models used by modules
- [Integration Architecture](../05-integration-architecture/README.md) - Integration patterns and adapters
- [Event-Driven Architecture](../02-framework-core/event-driven-architecture/eca-seca-overview.md) - ECA/SECA for decoupling
- [Extension Points](../08-extension-points/README.md) - Safe customization patterns

## Learning Path

**For Architects Planning Module Replacement**:
1. Start with [Module Architecture Overview](module-architecture-overview.md) to understand core vs optional
2. Read [Module Replacement Patterns](module-replacement-patterns.md) for replacement strategies
3. Study specific integration examples (QuickBooks, Salesforce, Stripe)
4. Review [Data Synchronization](../05-integration-architecture/data-synchronization.md) for sync patterns
5. Read [Circuit Breaker Patterns](../05-integration-architecture/circuit-breaker-patterns.md) for resilience

**For Integration Specialists**:
1. Review the module you're replacing (e.g., [Accounting Module](optional-modules/accounting-module.md))
2. Study the relevant integration example (e.g., [QuickBooks Integration](external-integration-examples/quickbooks-integration.md))
3. Read [External Service Adapters](../05-integration-architecture/external-service-adapters.md) for adapter patterns
4. Review [Data Synchronization](../05-integration-architecture/data-synchronization.md) for sync strategies

**For Developers Understanding Module Boundaries**:
1. Read [Module Architecture Overview](module-architecture-overview.md) for module organization
2. Study [Module Isolation Techniques](module-isolation-techniques.md) for dependency management
3. Review [ECA/SECA Overview](../02-framework-core/event-driven-architecture/eca-seca-overview.md) for decoupling
4. Read core module documentation to understand what cannot be disabled

## Important Notes

### Core vs Optional Modules

**Core Modules (Cannot be Disabled)**:
- **Party Module**: Used throughout the system for customers, suppliers, employees, organizations
- **Product Module**: Core to catalog, inventory, pricing, and most business operations
- **Order Module**: Fundamental to sales, purchasing, and transaction processing

These modules are deeply integrated and disabling them would break the system. However, you can:
- Extend them with custom entities and services
- Integrate with external systems for specific functions
- Use hybrid architectures (OFBiz + external system)

**Optional Modules (Can be Disabled or Replaced)**:
- **Accounting Module**: Can be replaced with QuickBooks, NetSuite, or other accounting systems
- **Manufacturing Module**: Can be disabled if not doing manufacturing
- **Marketing Module**: Can be disabled or replaced with marketing automation platforms
- **Human Resources Module**: Can be replaced with dedicated HR systems

### Module Replacement Strategies

1. **Full Replacement**: Replace entire module with external system (e.g., QuickBooks for accounting)
2. **Hybrid Architecture**: Use OFBiz for some functions, external system for others
3. **Service Adapter Pattern**: Implement OFBiz service interfaces that delegate to external systems
4. **Data Synchronization**: Keep data synchronized between OFBiz and external systems
5. **Event-Driven Integration**: Use ECA/SECA or message queues for loose coupling

### ECA/SECA Importance

ECA (Entity Condition Actions) and SECA (Service Event Condition Actions) are essential for module decoupling. They allow modules to react to events without direct dependencies. While you can replace ECA/SECA with alternative event systems (Kafka, RabbitMQ), you cannot disable event-driven mechanisms without breaking module interactions.

### Integration Examples

The external integration examples (QuickBooks, Salesforce, Stripe) are real-world patterns showing:
- Architecture diagrams for integration
- Data flow between systems
- Service adapter implementations
- Data mapping and synchronization strategies
- Error handling and resilience patterns

---

**Up**: [Master Index](../00-INDEX.md)  
**Previous**: [Data Architecture](../03-data-architecture/README.md)  
**Next**: [Integration Architecture](../05-integration-architecture/README.md)
