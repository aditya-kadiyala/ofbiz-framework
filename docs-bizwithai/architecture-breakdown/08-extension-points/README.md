# 08. Extension Points

## Overview

This section documents OFBiz extension mechanisms, customization patterns, API stability, and upgrade compatibility. Essential reading for anyone customizing or extending OFBiz to ensure safe, maintainable customizations.

## Contents

1. **[Plugin Architecture](plugin-architecture.md)** - Plugin system, lifecycle management, plugin loading sequence
2. **[Customization Patterns](customization-patterns.md)** - Safe customization patterns and anti-patterns to avoid
3. **[API Stability](api-stability.md)** - Public vs internal APIs, API classification, deprecation policy
4. **[Upgrade Compatibility](upgrade-compatibility.md)** - Backward compatibility guarantees, upgrade paths, migration strategies

## Key Concepts

- **Plugin System**: Isolated plugins with defined dependencies and lifecycle
- **Extension Points**: Well-defined points where customizations can be added safely
- **API Stability**: Clear distinction between stable public APIs and internal implementation
- **Safe Customization**: Patterns that survive upgrades vs anti-patterns that break
- **Backward Compatibility**: Guarantees and limitations for upgrades

## Who Should Read This Section?

- **Developers** building customizations or plugins
- **Technical Leads** establishing customization standards
- **Architects** designing extensible solutions
- **Upgrade Managers** planning version upgrades
- **Plugin Developers** creating reusable plugins

## Prerequisites

Before reading this section, you should understand:
- [Framework Core](../02-framework-core/README.md) - Framework components to extend
- [Application Modules](../04-application-modules/README.md) - Module architecture

## Related Sections

- [Framework Core](../02-framework-core/README.md) - Components being extended
- [Application Modules](../04-application-modules/README.md) - Module customization
- [Maintainability](../09-quality-attributes/maintainability.md) - Code organization

---

**Up**: [Master Index](../00-INDEX.md)  
**Previous**: [Cross-Cutting Concerns](../07-cross-cutting-concerns/README.md)  
**Next**: [Quality Attributes](../09-quality-attributes/README.md)
