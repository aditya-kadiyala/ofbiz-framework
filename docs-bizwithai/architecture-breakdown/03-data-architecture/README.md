# 03. Data Architecture

## Overview

This section documents OFBiz data architecture, including the complete entity model, domain-specific ERDs, caching strategies, multi-tenancy, data governance, scalability patterns, and security. Understanding the data architecture is essential for customization, integration, and performance optimization.

## Contents

### Entity Models
1. **[Entity Model Overview](entity-model-overview.md)** - Complete OFBiz entity model ERD (high-level)
2. **Domain Models**:
   - **[Party Domain](domain-models/party-domain.md)** - Party, Person, PartyGroup, PartyRole entities
   - **[Product Domain](domain-models/product-domain.md)** - Product, ProductCategory, ProductFeature, inventory
   - **[Order Domain](domain-models/order-domain.md)** - OrderHeader, OrderItem, OrderRole, order lifecycle
   - **[Accounting Domain](domain-models/accounting-domain.md)** - GlAccount, AcctgTrans, Invoice, financial relationships

### Data Management
3. **[Caching Strategy](caching-strategy.md)** - Cache architecture, layers (entity, service, view), invalidation
4. **[Multi-Tenancy Architecture](multi-tenancy-architecture.md)** - Data isolation, tenant delegation, segregation strategies
5. **[Data Governance](data-governance.md)** - Master data management, data quality, lifecycle management
6. **[Scalability Patterns](scalability-patterns.md)** - Database sharding, read replicas, clustering
7. **[Security & Encryption](security-encryption.md)** - Encryption at rest/transit, data masking, PII protection

## Key Concepts

- **Universal Data Model**: OFBiz uses a highly normalized, flexible data model that can adapt to various business scenarios
- **Domain-Driven Design**: Entities organized by business domains (Party, Product, Order, Accounting)
- **Party Model**: Universal party model representing people, organizations, and their roles
- **Multi-Layer Caching**: Entity cache, service result cache, and view cache for performance
- **Multi-Tenancy**: Built-in support for data isolation across multiple tenants
- **Audit Trail**: Comprehensive audit logging for compliance and governance

## Who Should Read This Section?

- **Database Architects** designing data models or integration strategies
- **Developers** working with entities and data access
- **Data Engineers** optimizing queries and caching
- **Integration Specialists** synchronizing data with external systems
- **Compliance Officers** understanding audit and data privacy capabilities

## Prerequisites

Before reading this section, you should understand:
- [Entity Engine Overview](../02-framework-core/entity-engine/overview.md) - How OFBiz accesses data
- [System Overview](../01-system-overview/README.md) - High-level architecture
- Basic database concepts (normalization, relationships, transactions)

## Related Sections

- [Entity Engine](../02-framework-core/entity-engine/overview.md) - Data access layer
- [Application Modules](../04-application-modules/README.md) - How modules use domain models
- [Integration Architecture](../05-integration-architecture/README.md) - Data synchronization patterns
- [Governance & Compliance](../10-governance-compliance/README.md) - Audit trails and data privacy

## Learning Path

**For Database Architects**:
1. Start with [Entity Model Overview](entity-model-overview.md) to see the complete data model
2. Study domain-specific ERDs for areas of interest
3. Review [Multi-Tenancy Architecture](multi-tenancy-architecture.md) if supporting multiple tenants
4. Read [Scalability Patterns](scalability-patterns.md) for large-scale deployments

**For Developers**:
1. Review [Entity Model Overview](entity-model-overview.md) for overall structure
2. Focus on domain models relevant to your work (Party, Product, Order, Accounting)
3. Study [Caching Strategy](caching-strategy.md) for performance optimization
4. Read [Entity Engine Query Engine](../02-framework-core/entity-engine/query-engine.md) for query patterns

**For Integration Specialists**:
1. Understand domain models you'll be synchronizing
2. Review [Data Governance](data-governance.md) for master data management
3. Study [Data Synchronization](../05-integration-architecture/data-synchronization.md) patterns
4. Read [Multi-Tenancy Architecture](multi-tenancy-architecture.md) if integrating multi-tenant systems

**For Compliance Officers**:
1. Review [Security & Encryption](security-encryption.md) for data protection
2. Study [Data Privacy & GDPR](../10-governance-compliance/data-privacy-gdpr.md) for compliance
3. Read [Audit Trail Architecture](../10-governance-compliance/audit-trail-architecture.md) for audit capabilities

## Important Notes

### Universal Data Model

OFBiz uses a highly flexible, normalized data model that can represent complex business scenarios. This flexibility comes with a learning curve - the data model is more abstract than typical application-specific models.

### Party Model

The Party model is central to OFBiz - it represents people, organizations, and their relationships. Understanding the Party model is essential for working with customers, suppliers, employees, and any other business entities.

### Core Domain Models

- **Party Domain**: Cannot be disabled - used throughout the system
- **Product Domain**: Cannot be disabled - core to most business operations
- **Order Domain**: Cannot be disabled - fundamental to transaction processing
- **Accounting Domain**: Can be replaced with external accounting systems (e.g., QuickBooks)

### Data Modification

When customizing OFBiz:
- **Extend, don't modify**: Add new entities rather than modifying existing ones
- **Use views**: Create database views for custom queries
- **Respect relationships**: Maintain referential integrity
- **Follow naming conventions**: Use consistent entity and field naming

---

**Up**: [Master Index](../00-INDEX.md)  
**Previous**: [Framework Core](../02-framework-core/README.md)  
**Next**: [Application Modules](../04-application-modules/README.md)
