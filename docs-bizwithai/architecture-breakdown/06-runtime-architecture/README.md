# 06. Runtime Architecture

## Overview

This section documents OFBiz runtime architecture, covering bootstrap sequence, request lifecycle, threading model, classloading, and JVM tuning. Essential for understanding how OFBiz operates at runtime and for performance optimization.

## Contents

1. **[Bootstrap Sequence](bootstrap-sequence.md)** - OFBiz startup sequence, component loading, initialization phases
2. **[Request Lifecycle](request-lifecycle.md)** - Complete HTTP request-to-response flow, from controller to database and back
3. **[Thread Model](thread-model.md)** - Thread pool configuration, concurrency patterns, async execution
4. **[Classloading Architecture](classloading-architecture.md)** - Component classloader isolation, dependency management
5. **[JVM Tuning](jvm-tuning.md)** - Memory management, GC tuning, performance optimization

## Key Concepts

- **Bootstrap Sequence**: Multi-phase startup process loading components, initializing services, and preparing the runtime
- **Request Lifecycle**: HTTP request flows through controller, events, services, entity engine, and back
- **Thread Pools**: Separate thread pools for web requests, async services, and scheduled jobs
- **Classloader Isolation**: Each component has its own classloader for dependency isolation
- **JVM Optimization**: Proper JVM tuning is critical for OFBiz performance

## Who Should Read This Section?

- **Performance Engineers** optimizing OFBiz performance
- **DevOps Engineers** deploying and tuning OFBiz
- **Developers** understanding request flow and debugging
- **System Administrators** troubleshooting runtime issues
- **Architects** understanding runtime characteristics

## Prerequisites

Before reading this section, you should understand:
- [System Overview](../01-system-overview/README.md) - Component-based architecture
- [Framework Core](../02-framework-core/README.md) - Entity Engine, Service Engine, Webapp Framework
- Basic Java runtime concepts (threads, classloaders, JVM)

## Related Sections

- [Framework Core](../02-framework-core/README.md) - Components that execute at runtime
- [Performance Characteristics](../09-quality-attributes/performance-characteristics.md) - Performance optimization
- [Deployment Topologies](../01-system-overview/deployment-topologies.md) - Deployment patterns

---

**Up**: [Master Index](../00-INDEX.md)  
**Previous**: [Integration Architecture](../05-integration-architecture/README.md)  
**Next**: [Cross-Cutting Concerns](../07-cross-cutting-concerns/README.md)
