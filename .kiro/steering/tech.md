# Technology Stack & Build System

## Core Technologies

### Language & Runtime
- **Java 17+**: Primary language (source and target compatibility)
- **Groovy 4.x**: Scripting and testing
- **Minilang**: OFBiz-specific business process language (XML-based)

### Build System
- **Gradle**: Build automation and dependency management
- **Gradle Wrapper**: Included (gradlew/gradlew.bat) - no separate Gradle installation needed

### Web & Application Server
- **Apache Tomcat 10.1** (Catalina): Embedded servlet container
- **Servlet API**: Jakarta Servlet specification

### Database Support
- **Apache Derby**: Default embedded database
- **PostgreSQL**: Recommended for production
- **MySQL/MariaDB**: Supported
- **Oracle**: Supported
- Custom Entity Engine (ORM) abstracts database differences

### Key Libraries
- **FreeMarker**: Template engine
- **Apache Commons**: Various utilities (CLI, Collections, etc.)
- **JUnit 4**: Unit testing
- **Checkstyle 10.x**: Java code quality
- **CodeNarc**: Groovy code quality
- **AsciiDoctor**: Documentation generation

## Common Commands

### Initial Setup
```bash
# Windows
init-gradle-wrapper.bat

# Unix/Linux/Mac
./gradle/init-gradle-wrapper.sh
```

### Build & Compile
```bash
# Clean and build
gradlew clean build

# Clean all generated artifacts
gradlew cleanAll

# Compile without Xlint warnings
gradlew -PXlint:none build
```

### Data Loading
```bash
# Load all data (seed, demo, etc.) - WARNING: Deletes existing data
gradlew loadAll

# Load only seed data
gradlew "ofbiz --load-data readers=seed"

# Load seed and seed-initial data
gradlew "ofbiz --load-data readers=seed,seed-initial"

# Load from specific file
gradlew "ofbiz --load-data file=path/to/data.xml"
```

### Running OFBiz
```bash
# Start OFBiz (default)
gradlew ofbiz

# Start with explicit command
gradlew "ofbiz --start"

# Start in background
gradlew ofbizBackground

# Start with port offset
gradlew "ofbiz --start --portoffset 10000"

# Start in debug mode (listens on port 5005)
gradlew ofbiz --debug-jvm

# Shutdown OFBiz
gradlew "ofbiz --shutdown"

# Force terminate (if shutdown fails)
gradlew terminateOfbiz

# Check status
gradlew "ofbiz --status"
```

### Testing
```bash
# Run unit tests (no DB access required)
gradlew test

# Run integration tests (requires DB)
gradlew testIntegration

# Run all tests on clean system
gradlew cleanAll loadAll testIntegration

# Run specific component tests
gradlew "ofbiz --test component=entity"

# Run specific test suite
gradlew "ofbiz --test component=entity --test suitename=entitytests"

# Run with debug
gradlew "ofbiz --test component=entity" --debug-jvm
```

### Code Quality
```bash
# Run Checkstyle (Java)
gradlew checkstyleMain

# Run CodeNarc (Groovy)
gradlew codenarcMain codenarcTest

# Run OWASP dependency check
gradlew -PenableOwasp dependencyCheckAnalyze
```

### Documentation
```bash
# Generate README files
gradlew generateReadmeFiles

# Generate OFBiz documentation
gradlew generateOfbizDocumentation

# Generate Javadoc
gradlew javadoc
```

### Plugin Management
```bash
# Pull plugin from repository
gradlew pullPlugin -PdependencyId="org.apache.ofbiz.plugin:myplugin:0.1.0"

# Install local plugin
gradlew installPlugin -PpluginId=myplugin

# Uninstall plugin
gradlew uninstallPlugin -PpluginId=myplugin

# Remove plugin (uninstall + delete)
gradlew removePlugin -PpluginId=myplugin

# Create new plugin
gradlew createPlugin -PpluginId=myplugin
```

### User Management
```bash
# Create admin user (password: ofbiz)
gradlew loadAdminUserLogin -PuserLoginId=MyUserName
```

### Multi-Tenancy
```bash
# Create new tenant
gradlew createTenant -PtenantId=mytenant

# Create tenant with options
gradlew createTenant -PtenantId=mytenant -PtenantName="My Company" -PdbPlatform=P

# Load tenant data
gradlew loadTenant -PtenantId=mytenant -PtenantReaders=seed,seed-initial
```

### Distribution
```bash
# Create tar distribution
gradlew distTar

# Create zip distribution
gradlew distZip
```

## Build Configuration

### JVM Arguments
Default: `-Xms128M -Xmx1024M`

Custom JVM args:
```bash
gradlew ofbiz -PjvmArgs="-Xms1024M -Xmx2048M"
```

### Gradle Properties
- Located in `gradle.properties`
- Console output: `org.gradle.console=plain`
- Heap memory can be adjusted via `org.gradle.jvmargs`

## IDE Setup

### Eclipse
```bash
# Generate Eclipse project files
gradlew eclipse

# Clean Eclipse files
gradlew cleanEclipse
```

## Code Conventions

### Java
- **Encoding**: UTF-8
- **Compiler warnings**: Xlint:all enabled by default (except varargs)
- **Checkstyle**: Enforced with zero tolerance for new violations
- **Max errors**: 0 (checkstyleMain.maxErrors = 0)

### Groovy
- **CodeNarc**: Enforced with zero tolerance
- **Priority violations**: All priorities set to max 0

### Excluded Java Sources
Some third-party payment gateway integrations are excluded from compilation:
- CyberSource, Orbital, PayPal, SecurePay, Verisign payment services
- Taxware integration services

## Default Ports
- **HTTPS**: 8443 (default web interface)
- **HTTP**: 8080
- **Debug**: 5005 (when using --debug-jvm)

## Default Credentials
- **Username**: admin
- **Password**: ofbiz

## Platform-Specific Notes

### Windows
- Requires PowerShell 7.1.3+
- Do NOT place OFBiz in directories with spaces in the path
- Use `gradlew.bat` or `gradlew` (both work)

### Unix/Linux/Mac
- Use `./gradlew` (requires execute permission)
- Shell scripts: `*.sh` files

## Git Hooks
Pre-push hooks run: `checkstyleMain codenarcMain codenarcTest`
