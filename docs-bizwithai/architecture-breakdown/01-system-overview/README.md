# 01. System Overview

## Overview

This section provides a high-level understanding of Apache OFBiz architecture, covering system boundaries, modular design, deployment patterns, technology choices, and architectural philosophy. Start here to understand the big picture before diving into specific components.

## Contents

1. **[System Context](system-context.md)** - External system boundaries, integration points, and stakeholder identification
2. **[Modular Architecture](modular-architecture.md)** - Component-based design, framework vs applications vs plugins, module dependencies
3. **[Deployment Topologies](deployment-topologies.md)** - Standalone, clustered, cloud, and containerized deployment patterns
4. **[Technology Stack](technology-stack.md)** - Technology choices, rationale, and architecture decision records
5. **[Architecture Philosophy](architecture-philosophy.md)** - Design principles, OFBiz unique characteristics, and comparison with other ERP systems

## Key Concepts

- **Modular Architecture**: OFBiz is built as a collection of loosely-coupled components that can be enabled, disabled, or replaced
- **Framework vs Applications**: Clear separation between framework core (Entity Engine, Service Engine) and business applications (Accounting, Manufacturing)
- **Component-Based Design**: Everything in OFBiz is a component with defined dependencies and lifecycle
- **Deployment Flexibility**: Can be deployed standalone, clustered, containerized, or in cloud environments
- **Technology Independence**: Designed to minimize vendor lock-in and maximize portability

## Who Should Read This Section?

- **Enterprise Architects** evaluating OFBiz for organizational use
- **Technical Decision Makers** assessing technology fit
- **Solution Architects** designing OFBiz-based solutions
- **New Developers** getting oriented to the system
- **Integration Architects** understanding system boundaries

## Prerequisites

No prerequisites - this is the starting point for understanding OFBiz architecture.

## Related Sections

- [Framework Core](../02-framework-core/README.md) - Deep dive into Entity Engine, Service Engine, and other framework components
- [Application Modules](../04-application-modules/README.md) - Business application modules and their architecture
- [Quality Attributes](../09-quality-attributes/README.md) - Performance, reliability, security, and other quality characteristics
- [Deployment Topologies](deployment-topologies.md) - Detailed deployment patterns

## Learning Path

**Recommended Reading Order**:
1. Start with [System Context](system-context.md) to understand external boundaries
2. Read [Modular Architecture](modular-architecture.md) to understand component organization
3. Review [Technology Stack](technology-stack.md) to see what OFBiz is built on
4. Explore [Deployment Topologies](deployment-topologies.md) to understand deployment options
5. Finish with [Architecture Philosophy](architecture-philosophy.md) to understand design principles

---

**Up**: [Master Index](../00-INDEX.md)  
**Next**: [System Context](system-context.md)
