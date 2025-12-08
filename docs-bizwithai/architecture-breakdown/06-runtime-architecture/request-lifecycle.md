# HTTP Request Lifecycle

**Document Type**: Runtime Architecture  
**Category**: Request Processing  
**Last Updated**: December 2024

---

## Overview

This document describes the complete lifecycle of an HTTP request in Apache OFBiz, from the moment it arrives at the web server through all processing layers until the response is returned to the client.

---

## Request Lifecycle Overview

### High-Level Request Flow

```mermaid
sequenceDiagram
    participant Browser
    participant Tomcat
    participant ControlServlet
    participant RequestHandler
    participant Event
    participant Service
    participant View
    
    Browser->>Tomcat: HTTP Request
    Tomcat->>ControlServlet: Forward Request
    ControlServlet->>RequestHandler: Process Request
    RequestHandler->>Event: Execute Event
    Event->>Service: Call Service
    Service-->>Event: Service Result
    Event-->>RequestHandler: Event Result
    RequestHandler->>View: Render View
    View-->>RequestHandler: Rendered Content
    RequestHandler-->>ControlServlet: Response
    ControlServlet-->>Tomcat: HTTP Response
    Tomcat-->>Browser: Send Response
```

---

## Detailed Request Processing

### Phase 1: Request Reception

```mermaid
flowchart TD
    Start([HTTP Request]) --> Connector[Tomcat Connector]
    Connector --> Filter1[ContextFilter]
    Filter1 --> Filter2[ControlFilter]
    Filter2 --> Servlet[ControlServlet]
    
    style Start fill:#e1f5ff
    style Servlet fill:#fff4e1
```

<details>
<summary><strong>ControlServlet - Main Entry Point</strong></summary>

**File**: `framework/webapp/src/main/java/org/apache/ofbiz/webapp/control/ControlServlet.java`

```java
public class ControlServlet extends HttpServlet {
    
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get request handler
        RequestHandler requestHandler = RequestHandler.getRequestHandler(getServletContext());
        
        try {
            // Process the request
            requestHandler.doRequest(request, response, null, null, null);
            
        } catch (RequestHandlerException e) {
            Debug.logError(e, "Error processing request", module);
            throw new ServletException(e);
        }
    }
}
```

</details>

### Phase 2: Request Mapping

```mermaid
flowchart TD
    Request[HTTP Request] --> Parse[Parse URL]
    Parse --> Extract[Extract Request URI]
    Extract --> Lookup[Lookup in controller.xml]
    Lookup --> Found{Request<br/>Mapping Found?}
    
    Found -->|Yes| LoadConfig[Load Request Config]
    Found -->|No| Error404[404 Not Found]
    
    LoadConfig --> CheckAuth[Check Authentication]
    CheckAuth --> CheckPerm[Check Permissions]
    CheckPerm --> Execute[Execute Request]
    
    style Request fill:#e1f5ff
    style Execute fill:#e1ffe1
    style Error404 fill:#ffe1e1
```

<details>
<summary><strong>Request Mapping Process</strong></summary>

**File**: `framework/webapp/src/main/java/org/apache/ofbiz/webapp/control/RequestHandler.java`

```java
public class RequestHandler {
    
    public void doRequest(HttpServletRequest request, HttpServletResponse response,
                         String chain, GenericValue userLogin, Delegator delegator) 
            throws RequestHandlerException {
        
        // Get request URI
        String requestUri = RequestHandler.getRequestUri(request.getPathInfo());
        
        // Lookup request map in controller.xml
        ConfigXMLReader.RequestMap requestMap = controllerConfig.getRequestMapMap().get(requestUri);
        
        if (requestMap == null) {
            throw new RequestHandlerException("Unknown request: " + requestUri);
        }
        
        // Check security
        if (requestMap.securityAuth) {
            if (!checkLogin(request, response)) {
                return; // Redirect to login
            }
        }
        
        // Check permissions
        if (requestMap.securityPermission != null) {
            if (!checkPermission(request, requestMap.securityPermission)) {
                throw new RequestHandlerException("Permission denied");
            }
        }
        
        // Execute request
        String eventReturn = runEvent(request, response, requestMap);
        
        // Render response
        renderResponse(request, response, requestMap, eventReturn);
    }
}
```

</details>

### Phase 3: Event Execution

```mermaid
sequenceDiagram
    participant RequestHandler
    participant EventFactory
    participant Event
    participant Service
    participant Delegator
    
    RequestHandler->>EventFactory: Get Event Handler
    EventFactory-->>RequestHandler: Event Instance
    
    RequestHandler->>Event: invoke()
    Event->>Event: Validate Parameters
    Event->>Service: Call Service
    Service->>Delegator: Database Operations
    Delegator-->>Service: Results
    Service-->>Event: Service Result
    Event->>Event: Process Result
    Event-->>RequestHandler: Event Return String
```

<details>
<summary><strong>Event Types and Execution</strong></summary>

**Java Event Handler**:

```java
// Java event handler
public class OrderEvents {
    
    public static String createOrder(HttpServletRequest request, HttpServletResponse response) {
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        GenericValue userLogin = (GenericValue) request.getSession().getAttribute("userLogin");
        
        try {
            // Get parameters from request
            String orderTypeId = request.getParameter("orderTypeId");
            String currencyUom = request.getParameter("currencyUom");
            
            // Prepare service context
            Map<String, Object> serviceContext = UtilHttp.getParameterMap(request);
            serviceContext.put("userLogin", userLogin);
            
            // Call service
            Map<String, Object> result = dispatcher.runSync("createOrder", serviceContext);
            
            if (ServiceUtil.isSuccess(result)) {
                String orderId = (String) result.get("orderId");
                request.setAttribute("orderId", orderId);
                request.setAttribute("_EVENT_MESSAGE_", "Order created successfully: " + orderId);
                return "success";
            } else {
                request.setAttribute("_ERROR_MESSAGE_", ServiceUtil.getErrorMessage(result));
                return "error";
            }
            
        } catch (GenericServiceException e) {
            Debug.logError(e, "Error creating order", module);
            request.setAttribute("_ERROR_MESSAGE_", e.getMessage());
            return "error";
        }
    }
}
```

**Service Event Handler**:

```xml
<!-- In controller.xml -->
<request-map uri="createOrder">
    <security https="true" auth="true"/>
    <event type="service" invoke="createOrder"/>
    <response name="success" type="view" value="OrderCreated"/>
    <response name="error" type="view" value="OrderForm"/>
</request-map>
```

</details>

### Phase 4: Service Invocation

```mermaid
flowchart TD
    Event[Event Handler] --> Validate[Validate Service Parameters]
    Validate --> Auth[Check Service Auth]
    Auth --> Permission[Check Service Permissions]
    Permission --> BeginTx[Begin Transaction]
    BeginTx --> Execute[Execute Service Logic]
    Execute --> ECA[Trigger ECA Rules]
    ECA --> CommitTx[Commit Transaction]
    CommitTx --> Return[Return Result]
    
    Execute -->|Error| Rollback[Rollback Transaction]
    Rollback --> Return
    
    style Event fill:#e1f5ff
    style Return fill:#e1ffe1
    style Rollback fill:#ffe1e1
```

<details>
<summary><strong>Service Execution Flow</strong></summary>

**File**: `framework/service/src/main/java/org/apache/ofbiz/service/ServiceDispatcher.java`

```java
public Map<String, Object> runSync(String serviceName, Map<String, ?> context) 
        throws ServiceException {
    
    ModelService model = ctx.getModelService(serviceName);
    
    // Validate parameters
    Map<String, Object> validated = model.makeValid(context, ModelService.IN_PARAM);
    
    // Check authentication
    if (model.auth && validated.get("userLogin") == null) {
        throw new ServiceAuthException("User login required");
    }
    
    // Check permissions
    if (model.permissionServiceName != null) {
        Map<String, Object> permResult = runSync(model.permissionServiceName, validated);
        if (!ServiceUtil.isSuccess(permResult)) {
            throw new ServiceAuthException("Permission denied");
        }
    }
    
    // Begin transaction
    boolean beganTransaction = false;
    try {
        if (model.useTransaction) {
            beganTransaction = TransactionUtil.begin();
        }
        
        // Get service engine
        GenericEngine engine = ctx.getGenericEngine(model.engineName);
        
        // Run service
        Map<String, Object> result = engine.runSync(serviceName, model, validated);
        
        // Trigger ECA rules
        ctx.getEcaHandler().evalRules(serviceName, validated, result, "return", false);
        
        // Commit transaction
        if (beganTransaction) {
            TransactionUtil.commit();
        }
        
        return result;
        
    } catch (Exception e) {
        if (beganTransaction) {
            TransactionUtil.rollback();
        }
        throw new ServiceException(e);
    }
}
```

</details>

### Phase 5: View Rendering

```mermaid
sequenceDiagram
    participant RequestHandler
    participant ViewFactory
    participant ScreenRenderer
    participant FreeMarker
    participant Response
    
    RequestHandler->>ViewFactory: Get View Handler
    ViewFactory-->>RequestHandler: View Instance
    
    RequestHandler->>ScreenRenderer: Render Screen
    ScreenRenderer->>ScreenRenderer: Load Screen XML
    ScreenRenderer->>ScreenRenderer: Process Widgets
    ScreenRenderer->>FreeMarker: Render Templates
    FreeMarker-->>ScreenRenderer: HTML Content
    ScreenRenderer-->>RequestHandler: Rendered Content
    
    RequestHandler->>Response: Write Response
    Response-->>RequestHandler: Complete
```

<details>
<summary><strong>View Rendering Process</strong></summary>

**File**: `framework/webapp/src/main/java/org/apache/ofbiz/webapp/view/ViewHandler.java`

```java
public interface ViewHandler {
    
    void render(String name, String page, String info, String contentType,
                String encoding, HttpServletRequest request, HttpServletResponse response) 
                throws ViewHandlerException;
}

// Screen view handler
public class ScreenViewHandler implements ViewHandler {
    
    @Override
    public void render(String name, String page, String info, String contentType,
                      String encoding, HttpServletRequest request, HttpServletResponse response) 
                      throws ViewHandlerException {
        
        try {
            // Set content type
            response.setContentType(contentType);
            response.setCharacterEncoding(encoding);
            
            // Get screen renderer
            ScreenRenderer screens = new ScreenRenderer(response.getWriter(), 
                request, response);
            
            // Render screen
            screens.render(page);
            
        } catch (Exception e) {
            throw new ViewHandlerException("Error rendering screen", e);
        }
    }
}
```

</details>

---

## Complete Request Flow Diagram

### End-to-End Request Processing

```mermaid
flowchart TD
    Start([HTTP Request<br/>GET /order/create]) --> Tomcat[Tomcat Receives Request]
    Tomcat --> ContextFilter[ContextFilter]
    ContextFilter --> ControlFilter[ControlFilter<br/>Setup Context]
    ControlFilter --> ControlServlet[ControlServlet]
    
    ControlServlet --> ParseURI[Parse URI: 'create']
    ParseURI --> LookupController[Lookup in controller.xml]
    LookupController --> CheckAuth{Auth<br/>Required?}
    
    CheckAuth -->|Yes| ValidateLogin{User<br/>Logged In?}
    CheckAuth -->|No| CheckPerm
    
    ValidateLogin -->|No| RedirectLogin[Redirect to Login]
    ValidateLogin -->|Yes| CheckPerm{Permission<br/>Required?}
    
    CheckPerm -->|Yes| ValidatePerm{Has<br/>Permission?}
    CheckPerm -->|No| ExecuteEvent
    
    ValidatePerm -->|No| Error403[403 Forbidden]
    ValidatePerm -->|Yes| ExecuteEvent[Execute Event Handler]
    
    ExecuteEvent --> EventType{Event<br/>Type?}
    EventType -->|Java| JavaEvent[Java Event Method]
    EventType -->|Service| ServiceEvent[Service Call]
    EventType -->|Simple| SimpleEvent[Simple Method]
    
    JavaEvent --> CallService[Call Service]
    ServiceEvent --> CallService
    SimpleEvent --> CallService
    
    CallService --> ValidateParams[Validate Parameters]
    ValidateParams --> BeginTx[Begin Transaction]
    BeginTx --> ExecuteService[Execute Service Logic]
    ExecuteService --> EntityOps[Entity Operations]
    EntityOps --> TriggerECA[Trigger ECA Rules]
    TriggerECA --> CommitTx[Commit Transaction]
    CommitTx --> ServiceResult[Service Result]
    
    ServiceResult --> EventResult{Event<br/>Result?}
    EventResult -->|success| SuccessView[Lookup Success View]
    EventResult -->|error| ErrorView[Lookup Error View]
    
    SuccessView --> RenderView[Render View]
    ErrorView --> RenderView
    
    RenderView --> LoadScreen[Load Screen XML]
    LoadScreen --> ProcessWidgets[Process Widgets]
    ProcessWidgets --> RenderFTL[Render FreeMarker]
    RenderFTL --> GenerateHTML[Generate HTML]
    GenerateHTML --> WriteResponse[Write to Response]
    WriteResponse --> End([HTTP Response])
    
    RedirectLogin --> End
    Error403 --> End
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
    style Error403 fill:#ffe1e1
    style RedirectLogin fill:#fff4e1
```

---

## Request Context

### Context Objects Available

```mermaid
graph TB
    Request[HttpServletRequest] --> Attributes[Request Attributes]
    Request --> Session[HTTP Session]
    Request --> Parameters[Request Parameters]
    
    Attributes --> Delegator[delegator]
    Attributes --> Dispatcher[dispatcher]
    Attributes --> Security[security]
    Attributes --> UserLogin[userLogin]
    
    Session --> SessionAttrs[Session Attributes]
    SessionAttrs --> Cart[shoppingCart]
    SessionAttrs --> Locale[locale]
    
    style Request fill:#e1f5ff
```

<details>
<summary><strong>Accessing Context Objects</strong></summary>

```java
// In event handler or service
public static String myEventHandler(HttpServletRequest request, HttpServletResponse response) {
    // Get framework objects
    Delegator delegator = (Delegator) request.getAttribute("delegator");
    LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
    Security security = (Security) request.getAttribute("security");
    
    // Get user login
    GenericValue userLogin = (GenericValue) request.getSession().getAttribute("userLogin");
    
    // Get request parameters
    String orderId = request.getParameter("orderId");
    
    // Get session attributes
    ShoppingCart cart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
    Locale locale = UtilHttp.getLocale(request);
    
    // Set request attributes for view
    request.setAttribute("orderId", orderId);
    request.setAttribute("_EVENT_MESSAGE_", "Success message");
    
    return "success";
}
```

</details>

---

## Performance Considerations

### Request Processing Time

```mermaid
gantt
    title Typical Request Processing Timeline
    dateFormat  SSS
    axisFormat %L
    
    section Network
    Request Arrival     :0, 5ms
    
    section Servlet
    Filter Chain        :5ms, 10ms
    ControlServlet      :15ms, 5ms
    
    section Processing
    Request Mapping     :20ms, 5ms
    Security Check      :25ms, 10ms
    Event Execution     :35ms, 20ms
    Service Call        :55ms, 50ms
    Database Query      :105ms, 30ms
    
    section Rendering
    View Rendering      :135ms, 40ms
    FreeMarker          :175ms, 25ms
    
    section Response
    Send Response       :200ms, 10ms
```

---

## Official References

- [Apache OFBiz Request Handling](https://cwiki.apache.org/confluence/display/OFBIZ/Request+Handling)
- [Controller Configuration](https://cwiki.apache.org/confluence/display/OFBIZ/Controller+Configuration)

---

## Related Documentation

- [Webapp Framework Overview](../02-framework-core/webapp-framework/overview.md)
- [Request Pipeline](../02-framework-core/webapp-framework/request-pipeline.md)
- [Service Engine](../02-framework-core/service-engine/overview.md)
- [Widget Framework](../02-framework-core/widget-framework/overview.md)

---

## Summary

An HTTP request in OFBiz flows through multiple layers: Tomcat connector, servlet filters, ControlServlet, request mapping, security checks, event execution, service invocation, and view rendering. The entire process typically takes 100-300ms depending on business logic complexity and database operations. Understanding this flow is essential for debugging, performance optimization, and custom development.
