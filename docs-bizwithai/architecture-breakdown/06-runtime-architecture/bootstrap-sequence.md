# OFBiz Bootstrap Sequence

**Document Type**: Runtime Architecture  
**Category**: System Initialization  
**Last Updated**: December 2024

---

## Overview

This document describes the complete bootstrap sequence of Apache OFBiz from JVM startup through component initialization and readiness for request processing. Understanding the bootstrap sequence is essential for troubleshooting startup issues and optimizing initialization time.

---

## Bootstrap Overview

### High-Level Bootstrap Flow

```mermaid
flowchart TD
    Start([JVM Start]) --> LoadContainer[Load Container Config]
    LoadContainer --> StartContainers[Start Containers]
    StartContainers --> LoadComponents[Load Components]
    LoadComponents --> InitEntity[Initialize Entity Engine]
    InitEntity --> InitService[Initialize Service Engine]
    InitService --> InitSecurity[Initialize Security]
    InitSecurity --> LoadData[Load Seed Data]
    LoadData --> StartWebapps[Start Web Applications]
    StartWebapps --> Ready([System Ready])
    
    style Start fill:#e1f5ff
    style Ready fill:#e1ffe1
    style InitEntity fill:#fff4e1
    style InitService fill:#fff4e1
```

---

## Detailed Bootstrap Sequence

### Phase 1: Container Initialization

```mermaid
sequenceDiagram
    participant Main
    participant StartupLoader
    participant ContainerConfig
    participant Containers
    
    Main->>StartupLoader: main()
    StartupLoader->>ContainerConfig: Load framework/base/config/ofbiz-containers.xml
    ContainerConfig-->>StartupLoader: Container Definitions
    
    loop For each container
        StartupLoader->>Containers: start(args)
        Containers->>Containers: Initialize
        Containers-->>StartupLoader: Started
    end
    
    StartupLoader-->>Main: Bootstrap Complete
```

<details>
<summary><strong>StartupLoader.java - Main Entry Point</strong></summary>

**File**: `framework/start/src/main/java/org/apache/ofbiz/base/start/StartupLoader.java`

```java
public class StartupLoader {
    
    public static void main(String[] args) throws Exception {
        // Parse command line arguments
        Config config = new Config(args);
        
        // Initialize logging
        initializeLogging(config);
        
        // Load container configuration
        ContainerConfig containerConfig = ContainerConfig.getConfiguration("ofbiz-containers.xml");
        
        // Start containers in order
        List<Container> containers = new ArrayList<>();
        for (ContainerConfig.Configuration containerCfg : containerConfig.getConfigurations()) {
            Container container = loadContainer(containerCfg);
            container.start();
            containers.add(container);
        }
        
        // Register shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            for (Container container : containers) {
                try {
                    container.stop();
                } catch (Exception e) {
                    Debug.logError(e, "Error stopping container", module);
                }
            }
        }));
        
        Debug.logInfo("OFBiz startup complete", module);
    }
}
```

</details>

### Phase 2: Component Loading

```mermaid
flowchart TD
    Start[Component Loader Start] --> ReadConfig[Read component-load.xml]
    ReadConfig --> ScanDirs[Scan Component Directories]
    ScanDirs --> LoadMeta[Load Component Metadata]
    LoadMeta --> ResolveDeps[Resolve Dependencies]
    ResolveDeps --> SortComponents[Topological Sort]
    SortComponents --> LoadComponents[Load in Dependency Order]
    LoadComponents --> End[Components Loaded]
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
```

<details>
<summary><strong>Component Loading Process</strong></summary>

**File**: `framework/base/src/main/java/org/apache/ofbiz/base/component/ComponentConfig.java`

```java
public class ComponentConfig {
    
    public static void loadComponents() throws ComponentException {
        // Read component-load.xml
        Document document = UtilXml.readXmlDocument(
            "framework/base/config/component-load.xml");
        
        List<ComponentConfig> components = new ArrayList<>();
        
        // Load component definitions
        for (Element loadComponent : UtilXml.childElementList(document.getDocumentElement())) {
            String location = loadComponent.getAttribute("component-location");
            
            // Read ofbiz-component.xml from each component
            ComponentConfig config = new ComponentConfig(location);
            components.add(config);
        }
        
        // Resolve dependencies
        List<ComponentConfig> sorted = resolveDependencies(components);
        
        // Load components in order
        for (ComponentConfig component : sorted) {
            loadComponent(component);
        }
    }
    
    private static void loadComponent(ComponentConfig component) {
        Debug.logInfo("Loading component: " + component.getComponentName(), module);
        
        // Load entity definitions
        for (ResourceInfo entityResource : component.getEntityResourceInfos()) {
            ModelReader.loadEntityModel(entityResource.location);
        }
        
        // Load service definitions
        for (ResourceInfo serviceResource : component.getServiceResourceInfos()) {
            DispatchContext.loadServiceDefinitions(serviceResource.location);
        }
        
        // Load webapp definitions
        for (WebappInfo webappInfo : component.getWebappInfos()) {
            WebAppUtil.registerWebapp(webappInfo);
        }
    }
}
```

</details>

### Phase 3: Entity Engine Initialization

```mermaid
sequenceDiagram
    participant Container
    participant Delegator
    participant ModelReader
    participant DataSource
    participant ConnectionPool
    
    Container->>Delegator: getDelegator()
    Delegator->>ModelReader: Load Entity Models
    ModelReader->>ModelReader: Parse entitymodel.xml files
    ModelReader-->>Delegator: Entity Definitions
    
    Delegator->>DataSource: Initialize Data Sources
    DataSource->>ConnectionPool: Create Connection Pools
    ConnectionPool-->>DataSource: Pools Ready
    DataSource-->>Delegator: Data Sources Ready
    
    Delegator->>Delegator: Load Entity Cache
    Delegator-->>Container: Entity Engine Ready
```

<details>
<summary><strong>Entity Engine Initialization</strong></summary>

**File**: `framework/entity/src/main/java/org/apache/ofbiz/entity/GenericDelegator.java`

```java
public class GenericDelegator implements Delegator {
    
    private void initialize() {
        Debug.logInfo("Initializing Entity Engine for delegator: " + delegatorName, module);
        
        // Load entity model
        this.modelReader = ModelReader.getModelReader(delegatorName);
        
        // Initialize data sources
        this.modelGroupReader = ModelGroupReader.getModelGroupReader(delegatorName);
        
        // Create connection pools
        for (String groupName : modelGroupReader.getGroupNames()) {
            String datasourceName = modelGroupReader.getDatasourceName(groupName);
            GenericHelperInfo helperInfo = getGroupHelperInfo(groupName);
            
            // Initialize connection pool
            GenericHelper helper = GenericHelperFactory.getHelper(helperInfo);
            this.helpers.put(groupName, helper);
        }
        
        // Initialize entity cache
        this.cache = new UtilCache<>("entity.default", 0, 0, true);
        
        Debug.logInfo("Entity Engine initialized successfully", module);
    }
}
```

</details>

### Phase 4: Service Engine Initialization

```mermaid
flowchart TD
    Start[Service Engine Init] --> LoadDefs[Load Service Definitions]
    LoadDefs --> ParseXML[Parse services.xml files]
    ParseXML --> CreateModels[Create ModelService objects]
    CreateModels --> InitEngines[Initialize Service Engines]
    InitEngines --> Java[Java Engine]
    InitEngines --> Simple[Simple Engine]
    InitEngines --> Entity[Entity-Auto Engine]
    InitEngines --> Script[Script Engines]
    
    Java --> Ready[Service Engine Ready]
    Simple --> Ready
    Entity --> Ready
    Script --> Ready
    
    style Start fill:#e1f5ff
    style Ready fill:#e1ffe1
```

<details>
<summary><strong>Service Engine Initialization</strong></summary>

**File**: `framework/service/src/main/java/org/apache/ofbiz/service/GenericDispatcher.java`

```java
public class GenericDispatcher implements LocalDispatcher {
    
    private void initialize() {
        Debug.logInfo("Initializing Service Engine for dispatcher: " + name, module);
        
        // Load service definitions
        this.ctx = new DispatchContext(name, delegator);
        
        // Register service engines
        registerServiceEngines();
        
        // Initialize job manager
        this.jobManager = JobManager.getInstance(delegator);
        
        // Start async service executor
        this.asyncExecutor = Executors.newFixedThreadPool(
            UtilProperties.getPropertyAsInteger("serviceengine.properties", 
                "thread.pool.size", 50)
        );
        
        Debug.logInfo("Service Engine initialized successfully", module);
    }
    
    private void registerServiceEngines() {
        // Java engine
        ServiceEngine javaEngine = new JavaEngine(ctx);
        ctx.registerServiceEngine("java", javaEngine);
        
        // Simple engine (minilang)
        ServiceEngine simpleEngine = new SimpleEngine(ctx);
        ctx.registerServiceEngine("simple", simpleEngine);
        
        // Entity-auto engine
        ServiceEngine entityAutoEngine = new EntityAutoEngine(ctx);
        ctx.registerServiceEngine("entity-auto", entityAutoEngine);
        
        // Script engines (Groovy, etc.)
        ServiceEngine scriptEngine = new ScriptEngine(ctx);
        ctx.registerServiceEngine("groovy", scriptEngine);
    }
}
```

</details>

### Phase 5: Security Initialization

```mermaid
sequenceDiagram
    participant Container
    participant Security
    participant PermissionReader
    participant Database
    
    Container->>Security: initialize()
    Security->>PermissionReader: Load Security Definitions
    PermissionReader->>Database: Query SecurityPermission
    Database-->>PermissionReader: Permission Data
    PermissionReader-->>Security: Permissions Loaded
    
    Security->>Security: Initialize Security Handlers
    Security-->>Container: Security Ready
```

### Phase 6: Data Loading

```mermaid
flowchart TD
    Start[Data Loading] --> SeedData[Load Seed Data]
    SeedData --> SeedInitial[Seed-Initial]
    SeedInitial --> Seed[Seed]
    Seed --> ExtSeed[Ext Seed]
    ExtSeed --> ExtData[Ext Data]
    ExtData --> Demo[Demo Data]
    Demo --> End[Data Loaded]
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
```

<details>
<summary><strong>Data Loading Process</strong></summary>

**File**: `framework/entity/src/main/java/org/apache/ofbiz/entity/util/EntityDataLoader.java`

```java
public class EntityDataLoader {
    
    public static void loadData(Delegator delegator, String dataReaderName, List<String> dataTypes) {
        Debug.logInfo("Loading data for reader: " + dataReaderName, module);
        
        for (String dataType : dataTypes) {
            Debug.logInfo("Loading data type: " + dataType, module);
            
            // Get data files for this type
            List<URL> dataFiles = getDataFiles(dataReaderName, dataType);
            
            for (URL dataFile : dataFiles) {
                try {
                    Debug.logInfo("Loading data file: " + dataFile, module);
                    
                    // Parse XML data file
                    Document document = UtilXml.readXmlDocument(dataFile);
                    
                    // Load entities
                    List<GenericValue> entities = parseDataFile(delegator, document);
                    
                    // Store entities
                    delegator.storeAll(entities);
                    
                    Debug.logInfo("Loaded " + entities.size() + " records from " + dataFile, module);
                    
                } catch (Exception e) {
                    Debug.logError(e, "Error loading data file: " + dataFile, module);
                }
            }
        }
    }
}
```

</details>

### Phase 7: Web Application Startup

```mermaid
sequenceDiagram
    participant Container
    participant CatalinaContainer
    participant Tomcat
    participant Webapp
    
    Container->>CatalinaContainer: start()
    CatalinaContainer->>Tomcat: Initialize Embedded Tomcat
    Tomcat-->>CatalinaContainer: Tomcat Ready
    
    loop For each webapp
        CatalinaContainer->>Webapp: Deploy Webapp
        Webapp->>Webapp: Load web.xml
        Webapp->>Webapp: Initialize Filters
        Webapp->>Webapp: Initialize Servlets
        Webapp-->>CatalinaContainer: Webapp Ready
    end
    
    CatalinaContainer->>Tomcat: Start Connectors
    Tomcat-->>CatalinaContainer: Listening on Ports
    CatalinaContainer-->>Container: Web Container Ready
```

---

## Bootstrap Timeline

### Typical Startup Timeline

```mermaid
gantt
    title OFBiz Bootstrap Timeline
    dateFormat  s
    axisFormat %S
    
    section Initialization
    JVM Start           :0, 2s
    Load Containers     :2s, 1s
    
    section Component Loading
    Scan Components     :3s, 2s
    Load Entity Models  :5s, 3s
    Load Service Defs   :8s, 2s
    
    section Engine Init
    Entity Engine       :10s, 2s
    Service Engine      :12s, 2s
    Security Init       :14s, 1s
    
    section Data Loading
    Seed Data           :15s, 5s
    
    section Web Apps
    Deploy Webapps      :20s, 5s
    Start Connectors    :25s, 1s
    
    section Ready
    System Ready        :26s, 0s
```

---

## Startup Configuration

### Container Configuration

<details>
<summary><strong>ofbiz-containers.xml</strong></summary>

**File**: `framework/base/config/ofbiz-containers.xml`

```xml
<ofbiz-containers>
    <!-- Component Container - Loads all components -->
    <container name="component-container" 
               class="org.apache.ofbiz.base.container.ComponentContainer"/>
    
    <!-- Entity Engine Container -->
    <container name="delegator-container" 
               class="org.apache.ofbiz.entity.DelegatorContainer"/>
    
    <!-- Service Engine Container -->
    <container name="service-container" 
               class="org.apache.ofbiz.service.ServiceContainer">
        <property name="thread-pool-size" value="50"/>
        <property name="purge-job-days" value="30"/>
    </container>
    
    <!-- Catalina (Tomcat) Container -->
    <container name="catalina-container" 
               class="org.apache.ofbiz.catalina.container.CatalinaContainer">
        <property name="default-server" value="default-server"/>
        <property name="apps-context-reloadable" value="false"/>
        <property name="apps-cross-context" value="false"/>
        <property name="apps-distributable" value="false"/>
    </container>
</ofbiz-containers>
```

</details>

### Component Load Order

<details>
<summary><strong>component-load.xml</strong></summary>

**File**: `framework/base/config/component-load.xml`

```xml
<component-loader>
    <!-- Framework components (loaded first) -->
    <load-component component-location="framework/base"/>
    <load-component component-location="framework/entity"/>
    <load-component component-location="framework/service"/>
    <load-component component-location="framework/security"/>
    <load-component component-location="framework/webapp"/>
    <load-component component-location="framework/widget"/>
    
    <!-- Application components -->
    <load-component component-location="applications/party"/>
    <load-component component-location="applications/product"/>
    <load-component component-location="applications/order"/>
    <load-component component-location="applications/accounting"/>
    
    <!-- Plugin components (loaded last) -->
    <load-component component-location="plugins"/>
</component-loader>
```

</details>

---

## Troubleshooting Startup Issues

### Common Startup Problems

```mermaid
flowchart TD
    Problem{Startup<br/>Issue?} --> DB[Database Connection]
    Problem --> Comp[Component Loading]
    Problem --> Data[Data Loading]
    Problem --> Port[Port Conflict]
    
    DB --> CheckDB[Check entityengine.xml]
    Comp --> CheckComp[Check component-load.xml]
    Data --> CheckData[Check data files]
    Port --> CheckPort[Check port availability]
    
    style Problem fill:#ffe1e1
```

### Startup Logging

Enable detailed startup logging:

```properties
# In framework/base/config/debug.properties
log4j2.logger.startup.name=org.apache.ofbiz.base.start
log4j2.logger.startup.level=DEBUG

log4j2.logger.component.name=org.apache.ofbiz.base.component
log4j2.logger.component.level=DEBUG

log4j2.logger.entity.name=org.apache.ofbiz.entity
log4j2.logger.entity.level=INFO

log4j2.logger.service.name=org.apache.ofbiz.service
log4j2.logger.service.level=INFO
```

---

## Official References

- [Apache OFBiz Installation Guide](https://cwiki.apache.org/confluence/display/OFBIZ/Installation)
- [OFBiz Framework Documentation](https://cwiki.apache.org/confluence/display/OFBIZ/Framework+Introduction)

---

## Related Documentation

- [Request Lifecycle](request-lifecycle.md)
- [Thread Model](thread-model.md)
- [Classloading Architecture](classloading-architecture.md)
- [JVM Tuning](jvm-tuning.md)

---

## Summary

OFBiz bootstrap follows a well-defined sequence: container initialization, component loading, entity engine setup, service engine initialization, security configuration, data loading, and web application deployment. Understanding this sequence helps troubleshoot startup issues and optimize initialization time. The entire process typically takes 20-30 seconds on modern hardware with seed data.
