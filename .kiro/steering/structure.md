# Project Organization & Folder Structure

## Top-Level Directory Structure

```
ofbiz-framework/
├── framework/          # Core framework components (required)
├── applications/       # Business application modules
├── themes/            # UI themes and styling
├── plugins/           # Optional plugin components
├── runtime/           # Runtime data (logs, temp files, data)
├── build/             # Build output (generated)
├── gradle/            # Gradle wrapper files
├── config/            # Build tool configurations (checkstyle, codenarc)
├── docs/              # Documentation source files
├── lib/               # Manually managed libraries (rare)
├── build.gradle       # Main build configuration
├── settings.gradle    # Gradle project settings
├── common.gradle      # Shared Gradle utilities
├── dependencies.gradle # Dependency definitions
└── gradlew[.bat]      # Gradle wrapper executables
```

## Component Loading Order

Components are loaded in this order (defined in `framework/base/config/component-load.xml`):
1. **framework/** - Core framework components
2. **themes/** - UI themes
3. **applications/** - Business applications
4. **plugins/** - Optional plugins

## Framework Components (Core)

Located in `framework/` - these are the foundational components:

```
framework/
├── base/              # Core utilities, startup, configuration
├── entity/            # Entity Engine (ORM)
├── service/           # Service framework and dispatcher
├── security/          # Authentication and authorization
├── webapp/            # Web application framework
├── widget/            # UI widget rendering engine
├── catalina/          # Tomcat integration
├── common/            # Shared services and utilities
├── minilang/          # Minilang business process language
├── entityext/         # Extended entity features
├── datafile/          # Data file processing
├── webtools/          # Administrative web tools
├── testtools/         # Testing framework
├── start/             # Application startup
└── resources/         # Shared resources (fonts, templates)
```

## Application Components

Located in `applications/` - business domain modules:

```
applications/
├── datamodel/         # Shared data model definitions
├── party/             # Party management (customers, vendors, employees)
├── product/           # Product catalog and inventory
├── order/             # Order management (sales, purchase)
├── accounting/        # Financial and accounting
├── manufacturing/     # Manufacturing and production
├── marketing/         # Marketing campaigns and promotions
├── humanres/          # Human resources
├── workeffort/        # Work effort and project management
├── content/           # Content management system
├── commonext/         # Extended common services
└── securityext/       # Extended security features
```

## Standard Component Structure

Each component (framework, application, or plugin) follows this structure:

```
component-name/
├── ofbiz-component.xml    # Component descriptor (REQUIRED)
├── build.gradle           # Component-specific build config (optional)
├── config/                # Configuration files
├── data/                  # Seed and demo data (XML)
│   ├── *SeedData.xml      # Initial/seed data
│   ├── *DemoData.xml      # Demo/test data
│   └── *SecurityData.xml  # Security permissions
├── entitydef/             # Entity definitions (data model)
│   ├── entitymodel*.xml   # Entity definitions
│   └── eecas.xml          # Entity Event Condition Actions
├── servicedef/            # Service definitions
│   ├── services*.xml      # Service definitions
│   ├── secas.xml          # Service Event Condition Actions
│   └── groups.xml         # Service groups
├── minilang/              # Minilang scripts (legacy)
├── src/                   # Source code
│   ├── main/
│   │   ├── java/          # Java source files
│   │   ├── groovy/        # Groovy source files
│   │   └── resources/     # Resource files
│   └── test/
│       ├── java/          # Java test files
│       ├── groovy/        # Groovy test files
│       └── resources/     # Test resources
├── testdef/               # Test definitions
│   └── *tests.xml         # Integration test suites
├── template/              # FreeMarker templates
├── webapp/                # Web application files
│   └── component-name/
│       ├── WEB-INF/
│       │   ├── web.xml    # Web app descriptor
│       │   └── controller.xml  # Request mappings
│       ├── pages/         # FTL page templates
│       ├── includes/      # Reusable FTL includes
│       └── error/         # Error pages
├── widget/                # Widget definitions (UI)
│   ├── *Screens.xml       # Screen definitions
│   ├── *Forms.xml         # Form definitions
│   ├── *Menus.xml         # Menu definitions
│   └── *Trees.xml         # Tree definitions
└── dtd/                   # Custom DTD files (rare)
```

## Component Descriptor (ofbiz-component.xml)

Every component must have an `ofbiz-component.xml` file that defines:
- Component name and enabled status
- Resource loaders
- Classpath entries
- Entity resources (model, data, ECA)
- Service resources (model, ECA, groups)
- Test suites
- Web applications (mount points, permissions)

Example structure:
```xml
<ofbiz-component name="component-name">
    <resource-loader name="main" type="component"/>
    <classpath type="dir" location="config"/>
    
    <entity-resource type="model" reader-name="main" loader="main" location="entitydef/entitymodel.xml"/>
    <entity-resource type="data" reader-name="seed" loader="main" location="data/SeedData.xml"/>
    
    <service-resource type="model" loader="main" location="servicedef/services.xml"/>
    
    <webapp name="component-name" 
            title="Component Title"
            server="default-server"
            location="webapp/component-name"
            mount-point="/component-name"/>
</ofbiz-component>
```

## Runtime Directory

```
runtime/
├── catalina/          # Tomcat runtime files
├── data/              # Database files (Derby default)
├── indexes/           # Search indexes
├── logs/              # Application logs
│   ├── console.log    # Console output
│   └── test-results/  # Test reports
├── output/            # Generated output files
├── tempfiles/         # Temporary files
└── tmp/               # Temporary processing files
```

## Plugin Structure

Plugins in `plugins/` follow the same structure as applications but are optional and can be:
- Pulled from Maven repositories
- Developed locally
- Enabled/disabled independently

Official plugins include:
- `example` - Example plugin with React integration
- `ecommerce` - E-commerce storefront
- `assetmaint` - Asset maintenance
- `projectmgr` - Project management
- `scrum` - Scrum/Agile project management
- `birt` - Business Intelligence Reporting
- `lucene` - Full-text search
- `solr` - Apache Solr integration
- `rest-api` - REST API framework

## Theme Structure

```
themes/
├── common-theme/      # Base theme (shared resources)
├── flatgrey/          # Flat grey theme
├── rainbowstone/      # Rainbow stone theme
└── [custom-theme]/    # Custom themes
```

## Source Code Organization

### Java Package Structure
```
org.apache.ofbiz.
├── base/              # Base utilities
├── entity/            # Entity engine
├── service/           # Service framework
├── security/          # Security framework
├── webapp/            # Web framework
├── widget/            # Widget framework
├── [component]/       # Component-specific packages
│   ├── [domain]/      # Domain logic
│   └── test/          # Tests
```

### Naming Conventions
- **Entities**: PascalCase (e.g., `OrderHeader`, `ProductStore`)
- **Services**: camelCase (e.g., `createOrder`, `updateProduct`)
- **Screens**: PascalCase (e.g., `FindOrders`, `EditProduct`)
- **Forms**: PascalCase (e.g., `ListOrders`, `EditProductForm`)
- **Java Classes**: PascalCase (e.g., `OrderServices`, `ProductWorker`)
- **Java Methods**: camelCase (e.g., `createOrder`, `calculateTotal`)

## Data File Types

Data files are categorized by reader type:
- **seed**: Core system data (always loaded)
- **seed-initial**: Initial data (loaded once)
- **demo**: Demo/test data
- **ext**: External/custom data
- **ext-test**: External test data
- **ext-demo**: External demo data
- **tenant**: Multi-tenant configuration data

## Configuration Files

### Framework Configuration
- `framework/base/config/component-load.xml` - Component loading order
- `framework/entity/config/entityengine.xml` - Database configuration
- `framework/service/config/serviceengine.xml` - Service engine config
- `framework/security/config/security.properties` - Security settings
- `framework/catalina/config/catalina.properties` - Tomcat settings

### Application Configuration
- `applications/[component]/config/*.properties` - Component-specific settings

## Build Artifacts

Generated during build (in `build/`):
```
build/
├── classes/           # Compiled Java classes
├── libs/              # Generated JAR files
├── distributions/     # Distribution archives (tar/zip)
├── reports/           # Test and quality reports
├── asciidoc/          # Generated documentation
└── tmp/               # Temporary build files
```

## Key Files

- **build.gradle**: Main build configuration, tasks, dependencies
- **settings.gradle**: Multi-project setup, component discovery
- **common.gradle**: Shared Gradle functions (activeComponents, etc.)
- **dependencies.gradle**: Centralized dependency management
- **gradle.properties**: Gradle build properties
- **VERSION**: OFBiz version number
- **LICENSE**: Apache License 2.0
- **NOTICE**: Attribution notices

## Component Discovery

Components are discovered dynamically:
1. Read `framework/base/config/component-load.xml`
2. For each `<load-components parent-directory="...">`:
   - Check for `component-load.xml` in that directory
   - If exists, load components listed there
   - If not, scan for subdirectories with `ofbiz-component.xml`
3. Only load components where `enabled="true"` (or attribute not present)

## Best Practices

### File Organization
- Keep related files together in the same component
- Use standard directory names (entitydef, servicedef, widget, etc.)
- Place shared utilities in framework/common or framework/base
- Create new components for distinct business domains

### Component Design
- Each component should be self-contained
- Minimize dependencies between components
- Use services for inter-component communication
- Define clear interfaces via service definitions

### Naming
- Use descriptive, consistent names
- Follow OFBiz naming conventions
- Prefix custom components to avoid conflicts
- Use component name as package/directory prefix
