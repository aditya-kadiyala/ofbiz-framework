# Design Document: OFBiz – QuickBooks Accounting Integration Plugin

## 1. Overview / Introduction

### 1.1 Purpose
This document describes the design of a custom Apache OFBiz plugin that integrates QuickBooks Online with OFBiz's operational modules while maintaining QuickBooks as the single source of truth for all accounting data. The goal is to eliminate split-brain scenarios by implementing a hybrid sync strategy with real-time writes and batch reads.

### 1.2 Problem Statement
Organizations using OFBiz for ERP operations and QuickBooks for accounting face challenges with data consistency, duplicate entry, and split-brain scenarios. This integration eliminates these issues by establishing clear ownership boundaries and implementing a robust synchronization strategy.

### 1.3 Scope

**In Scope:**
- Real-time sync: OFBiz transactions → QuickBooks
- Batch sync: QuickBooks → OFBiz (reporting data only)
- Customers, Invoices, Payments, Chart of Accounts, Items
- OAuth 2.0 secure authentication
- Webhooks and CDC (Change Data Capture) integration
- Comprehensive error handling and retry mechanisms
- Audit trails and logging

**Out of Scope:**
- Changes to OFBiz core components/modules/applications
- Desktop QuickBooks (Online only)
- Complex QuickBooks custom reports
- Payroll and time tracking

## 2. Business Requirements

### 2.1 Ownership Boundaries
- **OFBiz owns:** Inventory, Shipping, Order Management, CRM, Manufacturing, Operations
- **QuickBooks owns:** All accounting (GL, AP, AR, Financial Reporting, Tax Management)
- **Single Source of Truth:** QuickBooks for all accounting data

### 2.2 Sync Strategy
- **Real-time writes:** OFBiz operational transactions → QuickBooks accounting entries
- **Batch reads:** QuickBooks accounting data → OFBiz cache tables (reporting only)
- **No duplicate accounting data:** Store in OFBiz but always treat QB as authoritative

### 2.3 Transaction Handling
- **Payment transactions:** Fail fast (prevent double transactions)
- **Operational transactions:** Retry mechanism (3 retries + exponential backoff)
- **Error classification:** 4xx = fail fast, 5xx/timeouts = retry

## 3. Functional Requirements

### 3.1 Real-time Data Flows (OFBiz → QuickBooks)
- Order Completion → Invoice Creation
- Payment Processing → Payment Recording
- Customer Creation → Customer Sync
- Product Creation → Item Sync
- GL Transactions → Journal Entries

### 3.2 Batch Data Flows (QuickBooks → OFBiz)
- Financial summaries for sales dashboards
- Payment data for commission calculations
- Account balances for operational reports
- COGS data for inventory valuation

### 3.3 Event Triggers
- **Real-time triggers:** Service interceptors using ECA rules
- **Batch triggers:** Scheduled jobs (nightly/hourly)
- **Webhook triggers:** QuickBooks change notifications
- **CDC triggers:** Change data capture from QuickBooks

### 3.4 Conflict Resolution
- QuickBooks data always wins for accounting information
- OFBiz operational data takes precedence for inventory/shipping
- Timestamp-based resolution for overlapping data

## 4. Non-Functional Requirements

### 4.1 Performance
- **Latency expectations:**
  - Payment processing: 2-3 seconds
  - Invoice creation: 1-2 seconds
  - Bulk operations: Async with progress indicators
- **Rate limit handling:** QB API limits (500 requests/app/company/minute)
- **Connection pooling and circuit breaker patterns**

### 4.2 Security
- OAuth 2.0 for QuickBooks Online
- Encrypted credential storage in OFBiz
- Audit trails for all sync operations
- Secure webhook endpoints with signature verification

### 4.3 Reliability
- **Transaction integrity:** Two-phase commit approach
- **Compensation transactions:** Rollback mechanisms
- **Queue management:** Failed transaction retry queues
- **Health monitoring:** Service availability checks

## 5. Technical Architecture

### 5.1 High-Level Architecture
```
OFBiz Operations → Plugin Interceptors → QB API (Real-time)
QB Webhooks/CDC → Plugin Handlers → OFBiz Cache Tables (Batch)
```

### 5.2 Plugin Structure
```
plugins/qb-connector/
├── ofbiz-component.xml
├── build.gradle
├── entitydef/
│   ├── entitymodel.xml (mapping tables)
│   └── entitygroup.xml
├── servicedef/
│   ├── services.xml
│   └── secas.xml (ECA rules)
├── src/main/java/
│   ├── api/ (QB API client)
│   ├── services/ (sync services)
│   ├── handlers/ (webhook handlers)
│   └── mappers/ (data transformation)
├── config/
│   ├── qb-connector.properties
│   └── oauth-config.xml
├── webapp/
│   ├── qb-connector/
│   └── WEB-INF/
├── data/
│   ├── QBConnectorSeedData.xml
│   └── QBConnectorDemoData.xml
└── docs/
    └── QB-Connector-Design.md
```

### 5.3 Key Components

#### 5.3.1 Real-time Sync Engine
- **Service Interceptors:** ECA rules for pre/post service execution
- **API Client:** QuickBooks Online API wrapper with retry logic
- **Transaction Manager:** Two-phase commit coordination
- **Error Handler:** Classification and retry mechanisms

#### 5.3.2 Batch Sync Engine
- **Scheduled Jobs:** Configurable batch processing
- **CDC Handler:** Change data capture from QuickBooks
- **Cache Manager:** Temporary storage for reporting data
- **Data Purger:** Regular cleanup of stale cache data

#### 5.3.3 Webhook Integration
- **Webhook Receiver:** Secure endpoint for QB notifications
- **Event Processor:** Handle QB change events
- **Signature Validator:** Verify webhook authenticity
- **Queue Manager:** Async processing of webhook events

## 6. Design Decisions

### 6.1 Sync Strategy: Hybrid (Real-time + Batch)
**Pros:** Eliminates split-brain, optimal performance, clear ownership
**Cons:** More complex than single strategy
**Decision:** Hybrid approach for best of both worlds

### 6.2 Data Storage: Cache with QB as Source of Truth
**Pros:** No split-brain, clear data lineage, reporting capability
**Cons:** Requires cache management
**Decision:** Store accounting data in OFBiz but always treat QB as authoritative

### 6.3 Error Handling: Transaction-specific Strategy
**Pros:** Prevents double transactions, maintains data integrity
**Cons:** Different logic paths
**Decision:** Fail fast for payments, retry for operations

### 6.4 Integration Method: Plugin-only Approach
**Pros:** No core changes, maintainable, upgradeable
**Cons:** Limited to plugin capabilities
**Decision:** Pure plugin approach to avoid core modifications

## 7. Data Model / Mapping Tables

### 7.1 Core Mapping Entities
```xml
<!-- QB_SYNC_STATUS -->
<entity entity-name="QBSyncStatus">
    <field name="syncId" type="id-ne"/>
    <field name="entityType" type="short-varchar"/>
    <field name="ofbizId" type="id"/>
    <field name="qbId" type="id"/>
    <field name="syncDirection" type="indicator"/>
    <field name="lastSyncTime" type="date-time"/>
    <field name="syncStatus" type="indicator"/>
    <prim-key field="syncId"/>
</entity>

<!-- QB_ERROR_LOG -->
<entity entity-name="QBErrorLog">
    <field name="errorId" type="id-ne"/>
    <field name="syncId" type="id"/>
    <field name="errorType" type="short-varchar"/>
    <field name="errorMessage" type="very-long"/>
    <field name="retryCount" type="numeric"/>
    <field name="createdDate" type="date-time"/>
    <prim-key field="errorId"/>
</entity>

<!-- QB_CACHE_DATA (for reporting) -->
<entity entity-name="QBCacheData">
    <field name="cacheId" type="id-ne"/>
    <field name="dataType" type="short-varchar"/>
    <field name="qbId" type="id"/>
    <field name="jsonData" type="very-long"/>
    <field name="lastUpdated" type="date-time"/>
    <field name="expiryDate" type="date-time"/>
    <prim-key field="cacheId"/>
</entity>
```

### 7.2 Field Mapping Examples

#### Customer Mapping
| OFBiz Field | QuickBooks Field | Notes |
|-------------|------------------|-------|
| partyId | Id | Primary mapping |
| firstName | GivenName | Individual customers |
| lastName | FamilyName | Individual customers |
| groupName | CompanyName | Business customers |
| emailAddress | PrimaryEmailAddr.Address | Contact info |
| phoneNumber | PrimaryPhone.FreeFormNumber | Contact info |

#### Invoice Mapping
| OFBiz Field | QuickBooks Field | Notes |
|-------------|------------------|-------|
| invoiceId | Id | Primary mapping |
| invoiceDate | TxnDate | Transaction date |
| partyIdFrom | CustomerRef.value | Customer reference |
| invoiceTotal | TotalAmt | Calculated total |
| currencyUomId | CurrencyRef.value | Currency code |

## 8. API Specifications

### 8.1 QuickBooks API Endpoints
- **Base URL:** `https://sandbox-quickbooks.api.intuit.com/v3/company/{companyId}`
- **Authentication:** OAuth 2.0 Bearer tokens
- **Rate Limits:** 500 requests per app per company per minute

#### Key Endpoints:
- `POST /customer` - Create customer
- `POST /invoice` - Create invoice  
- `POST /payment` - Record payment
- `GET /accounts` - Retrieve chart of accounts
- `POST /journalentry` - Create journal entry

### 8.2 Webhook Configuration
- **Endpoint:** `https://your-ofbiz.com/qb-connector/webhook`
- **Events:** Customer, Invoice, Payment, Account changes
- **Security:** HMAC-SHA256 signature verification
- **Payload:** JSON with entity type and change details

## 9. Service Layer Design

### 9.1 Real-time Services
```xml
<!-- Synchronous services for real-time sync -->
<service name="syncCustomerToQuickBooks" engine="java">
    <attribute name="partyId" type="String" mode="IN"/>
    <attribute name="qbCustomerId" type="String" mode="OUT"/>
</service>

<service name="syncInvoiceToQuickBooks" engine="java">
    <attribute name="invoiceId" type="String" mode="IN"/>
    <attribute name="qbInvoiceId" type="String" mode="OUT"/>
</service>

<service name="syncPaymentToQuickBooks" engine="java">
    <attribute name="paymentId" type="String" mode="IN"/>
    <attribute name="qbPaymentId" type="String" mode="OUT"/>
</service>
```

### 9.2 Batch Services
```xml
<!-- Asynchronous services for batch sync -->
<service name="batchSyncFromQuickBooks" engine="java">
    <attribute name="entityType" type="String" mode="IN"/>
    <attribute name="lastSyncTime" type="Timestamp" mode="IN"/>
</service>

<service name="refreshQBCacheData" engine="java">
    <attribute name="dataTypes" type="List" mode="IN"/>
</service>
```

### 9.3 ECA Rules for Real-time Triggers
```xml
<eca service="createInvoice" event="commit">
    <condition field-name="statusId" operator="equals" value="INVOICE_READY"/>
    <action service="syncInvoiceToQuickBooks" mode="sync"/>
</eca>

<eca service="createPayment" event="commit">
    <condition field-name="statusId" operator="equals" value="PMNT_CONFIRMED"/>
    <action service="syncPaymentToQuickBooks" mode="sync"/>
</eca>
```

## 10. Error Handling & Retry Strategy

### 10.1 Error Classification
- **4xx Errors:** Client errors - fail fast, log for manual review
- **5xx Errors:** Server errors - retry with exponential backoff
- **Timeout Errors:** Network issues - retry with backoff
- **Rate Limit Errors:** Pause and retry after rate limit reset

### 10.2 Retry Mechanism
```java
// Exponential backoff: 1s, 2s, 4s, then fail
RetryPolicy retryPolicy = RetryPolicy.builder()
    .maxRetries(3)
    .backoffMultiplier(2.0)
    .initialDelay(Duration.ofSeconds(1))
    .build();
```

### 10.3 Compensation Transactions
- Failed QB sync triggers rollback in OFBiz
- Partial failures stored in retry queue
- Manual reconciliation tools for persistent failures

## 11. Webhook & CDC Integration

### 11.1 Webhook Handler
```java
@WebServlet("/qb-connector/webhook")
public class QBWebhookHandler extends HttpServlet {
    // Verify signature, parse payload, queue for processing
}
```

### 11.2 CDC Implementation
- **Polling Strategy:** Regular queries for changed entities
- **Timestamp Tracking:** Last sync timestamps per entity type
- **Delta Processing:** Only process changed records
- **Batch Optimization:** Group changes for efficient processing

## 12. Configuration & Deployment

### 12.1 Configuration Properties
```properties
# QuickBooks API Configuration
qb.api.baseUrl=https://sandbox-quickbooks.api.intuit.com
qb.oauth.clientId=${QB_CLIENT_ID}
qb.oauth.clientSecret=${QB_CLIENT_SECRET}
qb.oauth.redirectUri=${QB_REDIRECT_URI}

# Sync Configuration
qb.sync.batchSize=100
qb.sync.retryAttempts=3
qb.sync.cacheExpiryHours=24

# Webhook Configuration
qb.webhook.verificationToken=${QB_WEBHOOK_TOKEN}
qb.webhook.endpoint=/qb-connector/webhook
```

### 12.2 Environment Setup
- **Sandbox:** Development and testing
- **Production:** Live QuickBooks company integration
- **OAuth Apps:** Separate apps for each environment

## 13. Testing Strategy

### 13.1 Unit Tests
- Data transformation and mapping logic
- Error handling and retry mechanisms
- OAuth token management
- Webhook signature verification

### 13.2 Integration Tests
- End-to-end sync scenarios using QB Sandbox
- Webhook event processing
- Batch sync operations
- Error recovery scenarios

### 13.3 Performance Tests
- Rate limit handling
- Bulk data synchronization
- Concurrent transaction processing
- Memory usage with large datasets

## 14. Monitoring & Observability

### 14.1 Metrics
- Sync success/failure rates
- API response times
- Error frequencies by type
- Queue depths and processing times

### 14.2 Logging
- Structured logging with correlation IDs
- API request/response summaries
- Error details with stack traces
- Performance metrics and timings

### 14.3 Alerting
- Failed sync notifications
- Rate limit warnings
- Authentication failures
- Queue backup alerts

## 15. Security Considerations

### 15.1 Authentication & Authorization
- OAuth 2.0 with PKCE for enhanced security
- Secure token storage and refresh
- Role-based access to sync functions
- API key rotation procedures

### 15.2 Data Protection
- Encryption in transit (HTTPS/TLS)
- Sensitive data masking in logs
- Webhook payload validation
- Input sanitization and validation

## 16. Future Enhancements

### 16.1 Phase 2 Features
- Advanced reconciliation dashboard
- Multi-company QuickBooks support
- Custom field mapping configuration
- Real-time sync status monitoring

### 16.2 Phase 3 Features
- Machine learning for mapping suggestions
- Advanced conflict resolution rules
- Integration with other accounting systems
- Mobile app for sync monitoring

## 17. Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| QB API changes | High | Medium | Version pinning, API monitoring |
| Rate limit exceeded | Medium | High | Intelligent batching, backoff |
| OAuth token expiry | Medium | Medium | Automatic refresh, monitoring |
| Data mapping errors | High | Low | Comprehensive validation, testing |
| Network connectivity | Medium | Medium | Retry mechanisms, offline queuing |

## 18. Success Criteria

### 18.1 Functional Success
- 99.9% sync success rate for critical transactions
- Sub-3-second response time for payment processing
- Zero split-brain scenarios in production
- Complete audit trail for all sync operations

### 18.2 Business Success
- Elimination of manual data entry
- Real-time financial visibility
- Reduced reconciliation effort
- Improved compliance and audit readiness

---

**Document Version:** 1.0  
**Last Updated:** December 10, 2025  
**Author:** System Architecture Team  
**Review Status:** Draft for Implementation
