# Deployment Topologies

**Purpose**: Document OFBiz deployment patterns including standalone, clustered, cloud, and containerized deployments  
**Audience**: DevOps Engineers, System Administrators, Solution Architects  
**Prerequisites**: [System Context](system-context.md), [Modular Architecture](modular-architecture.md)  
**Related Documents**: [Runtime Architecture](../06-runtime-architecture/README.md), [Performance Characteristics](../09-quality-attributes/performance-characteristics.md)

---

## Overview

Apache OFBiz supports multiple deployment topologies to meet different scalability, availability, and operational requirements. This document covers standalone, clustered, cloud-native, and containerized deployment patterns with architecture diagrams and configuration guidance.

## Visual Architecture

### Standalone Deployment

```mermaid
graph TB
    subgraph "Single Server"
        A[Load Balancer/Reverse Proxy<br/>nginx/Apache]
        B[OFBiz Application<br/>Tomcat/Jetty]
        C[Database<br/>PostgreSQL/MySQL]
        D[File Storage<br/>Local Filesystem]
    end

    E[Users] -->|HTTPS| A
    A -->|HTTP| B
    B -->|JDBC| C
    B -->|File I/O| D

    style B fill:#ffe1e1
    style C fill:#e1f5ff
```

**Diagram Description**: Standalone deployment runs all components on a single server. Users connect via load balancer/reverse proxy, which forwards to OFBiz application. OFBiz connects to local database and file storage. Suitable for development, testing, or small deployments.

### Clustered Deployment

```mermaid
graph TB
    subgraph "Load Balancer Tier"
        LB[Load Balancer<br/>HAProxy/nginx]
    end

    subgraph "Application Tier"
        A1[OFBiz Node 1]
        A2[OFBiz Node 2]
        A3[OFBiz Node 3]
    end

    subgraph "Data Tier"
        DB[(Database Cluster<br/>PostgreSQL/MySQL)]
        CACHE[Distributed Cache<br/>Redis/Memcached]
        FS[Shared File Storage<br/>NFS/S3]
    end

    U[Users] -->|HTTPS| LB
    LB -->|HTTP| A1
    LB -->|HTTP| A2
    LB -->|HTTP| A3

    A1 -->|JDBC| DB
    A2 -->|JDBC| DB
    A3 -->|JDBC| DB

    A1 -->|Cache| CACHE
    A2 -->|Cache| CACHE
    A3 -->|Cache| CACHE

    A1 -->|Files| FS
    A2 -->|Files| FS
    A3 -->|Files| FS

    style A1 fill:#ffe1e1
    style A2 fill:#ffe1e1
    style A3 fill:#ffe1e1
    style DB fill:#e1f5ff
```

**Diagram Description**: Clustered deployment distributes load across multiple OFBiz nodes. Load balancer routes requests to healthy nodes. All nodes share database cluster, distributed cache, and file storage. Provides high availability and horizontal scalability.


### Cloud Deployment (AWS Example)

```mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "Public Subnet"
            ALB[Application Load Balancer]
        end
        
        subgraph "Private Subnet - AZ1"
            A1[OFBiz Instance 1<br/>EC2]
        end
        
        subgraph "Private Subnet - AZ2"
            A2[OFBiz Instance 2<br/>EC2]
        end
        
        subgraph "Database Subnet"
            RDS[(RDS PostgreSQL<br/>Multi-AZ)]
        end
        
        subgraph "Storage"
            S3[S3 Bucket<br/>File Storage]
            ELASTIC[ElastiCache<br/>Redis]
        end
    end

    U[Users] -->|HTTPS| ALB
    ALB --> A1
    ALB --> A2
    A1 --> RDS
    A2 --> RDS
    A1 --> S3
    A2 --> S3
    A1 --> ELASTIC
    A2 --> ELASTIC

    style A1 fill:#ffe1e1
    style A2 fill:#ffe1e1
    style RDS fill:#e1f5ff
```

**Diagram Description**: Cloud deployment on AWS uses managed services. Application Load Balancer distributes traffic across availability zones. OFBiz instances run on EC2 in private subnets. RDS provides managed database with multi-AZ failover. S3 for file storage, ElastiCache for distributed caching.

### Containerized Deployment (Kubernetes)

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "Ingress"
            ING[Ingress Controller<br/>nginx/Traefik]
        end
        
        subgraph "OFBiz Pods"
            P1[OFBiz Pod 1]
            P2[OFBiz Pod 2]
            P3[OFBiz Pod 3]
        end
        
        subgraph "Services"
            SVC[OFBiz Service<br/>ClusterIP]
        end
        
        subgraph "StatefulSets"
            DB[(PostgreSQL<br/>StatefulSet)]
            REDIS[Redis<br/>StatefulSet]
        end
        
        subgraph "Storage"
            PV[Persistent Volumes]
        end
    end

    U[Users] -->|HTTPS| ING
    ING --> SVC
    SVC --> P1
    SVC --> P2
    SVC --> P3
    P1 --> DB
    P2 --> DB
    P3 --> DB
    P1 --> REDIS
    P2 --> REDIS
    P3 --> REDIS
    DB --> PV
    P1 --> PV
    P2 --> PV
    P3 --> PV

    style P1 fill:#ffe1e1
    style P2 fill:#ffe1e1
    style P3 fill:#ffe1e1
    style DB fill:#e1f5ff
```

**Diagram Description**: Kubernetes deployment uses pods for OFBiz instances with horizontal pod autoscaling. Ingress controller handles external traffic. StatefulSets for database and Redis. Persistent volumes for data storage. Provides cloud-native scalability and resilience.

## Deployment Patterns

### 1. Standalone Deployment

**Use Cases**:
- Development and testing environments
- Small businesses with limited traffic
- Proof of concept deployments
- Single-tenant SaaS with dedicated instances

**Characteristics**:
- Single server runs all components
- Simplest to deploy and manage
- Limited scalability and availability
- Lower infrastructure costs

**Configuration**:
- OFBiz application server (Tomcat/Jetty)
- Database (PostgreSQL, MySQL, Derby)
- Local file storage
- Optional reverse proxy (nginx, Apache)

**Pros**:
- ✅ Simple setup and maintenance
- ✅ Low infrastructure costs
- ✅ Easy to backup and restore
- ✅ Suitable for small deployments

**Cons**:
- ❌ Single point of failure
- ❌ Limited scalability
- ❌ No high availability
- ❌ Downtime during upgrades

### 2. Clustered Deployment

**Use Cases**:
- Production environments requiring high availability
- Medium to large businesses
- Multi-tenant SaaS platforms
- Applications with variable load

**Characteristics**:
- Multiple OFBiz nodes behind load balancer
- Shared database and file storage
- Distributed caching for performance
- Horizontal scalability

**Configuration**:
- Load balancer (HAProxy, nginx, AWS ALB)
- Multiple OFBiz application servers
- Database cluster (PostgreSQL, MySQL with replication)
- Shared file storage (NFS, S3, Azure Blob)
- Distributed cache (Redis, Memcached)

**Pros**:
- ✅ High availability (no single point of failure)
- ✅ Horizontal scalability (add more nodes)
- ✅ Rolling upgrades (zero downtime)
- ✅ Better performance under load

**Cons**:
- ❌ More complex setup and management
- ❌ Higher infrastructure costs
- ❌ Requires session management
- ❌ Need distributed cache coordination

### 3. Cloud Deployment

**Use Cases**:
- Organizations using cloud infrastructure
- Global deployments across regions
- Variable workloads requiring elasticity
- Disaster recovery requirements

**Characteristics**:
- Leverages cloud-managed services
- Auto-scaling based on load
- Multi-region deployment possible
- Pay-as-you-go pricing

**AWS Configuration**:
- Application Load Balancer (ALB)
- EC2 instances with Auto Scaling Groups
- RDS for database (Multi-AZ)
- S3 for file storage
- ElastiCache for distributed caching
- CloudWatch for monitoring

**Azure Configuration**:
- Azure Load Balancer
- Virtual Machine Scale Sets
- Azure Database for PostgreSQL
- Azure Blob Storage
- Azure Cache for Redis
- Azure Monitor

**GCP Configuration**:
- Cloud Load Balancing
- Compute Engine with Managed Instance Groups
- Cloud SQL for PostgreSQL
- Cloud Storage
- Memorystore for Redis
- Cloud Monitoring

**Pros**:
- ✅ Managed services reduce operational burden
- ✅ Auto-scaling for variable load
- ✅ Global reach with multiple regions
- ✅ Built-in backup and disaster recovery

**Cons**:
- ❌ Vendor lock-in concerns
- ❌ Can be expensive at scale
- ❌ Requires cloud expertise
- ❌ Data sovereignty considerations

### 4. Containerized Deployment

**Use Cases**:
- Cloud-native architectures
- DevOps teams using containers
- Multi-environment deployments (dev, staging, prod)
- Organizations using Kubernetes

**Characteristics**:
- OFBiz packaged as Docker containers
- Orchestrated by Kubernetes
- Declarative configuration
- Immutable infrastructure

**Configuration**:
- Docker images for OFBiz
- Kubernetes Deployments for application
- StatefulSets for database
- Persistent Volumes for data
- Ingress for external access
- ConfigMaps and Secrets for configuration

**Pros**:
- ✅ Consistent environments (dev = prod)
- ✅ Fast deployment and rollback
- ✅ Efficient resource utilization
- ✅ Cloud-portable (runs anywhere)

**Cons**:
- ❌ Kubernetes complexity
- ❌ Requires container expertise
- ❌ Stateful applications challenging
- ❌ Debugging more difficult

## Deployment Considerations

### Session Management

**Sticky Sessions**:
- Load balancer routes user to same node
- Simpler implementation
- Node failure loses sessions

**Session Replication**:
- Sessions replicated across nodes
- No session loss on node failure
- Higher memory and network overhead

**External Session Store**:
- Sessions stored in Redis/database
- Best for cloud deployments
- Slight performance overhead

### File Storage

**Local Filesystem**:
- Simplest approach
- Only works for standalone
- Not suitable for clusters

**Network File System (NFS)**:
- Shared storage across nodes
- Works for on-premise clusters
- Performance bottleneck possible

**Object Storage (S3, Azure Blob)**:
- Cloud-native approach
- Highly scalable and durable
- Best for cloud deployments

### Database Considerations

**Single Database**:
- Simplest configuration
- Potential bottleneck
- Single point of failure

**Database Replication**:
- Master for writes, replicas for reads
- Improves read performance
- Adds complexity

**Database Clustering**:
- Multiple masters (PostgreSQL, MySQL Cluster)
- High availability
- More complex setup

### Caching Strategy

**Local Cache Only**:
- Each node has own cache
- Cache inconsistency across nodes
- Only for standalone

**Distributed Cache**:
- Redis or Memcached cluster
- Consistent cache across nodes
- Required for clusters

**Hybrid Caching**:
- Local L1 cache + distributed L2 cache
- Best performance
- More complex configuration

## Architecture Decision Records

### ADR-005: Clustering Support

**Context**: Need to support high availability and horizontal scaling

**Decision**: Support clustered deployment with shared database and distributed cache

**Rationale**:
- High availability requirement for production
- Horizontal scaling for growing businesses
- Industry standard pattern

**Consequences**:
- ✅ High availability
- ✅ Horizontal scalability
- ❌ Increased complexity
- ❌ Requires session management

### ADR-006: Container Support

**Context**: Growing adoption of containers and Kubernetes

**Decision**: Provide official Docker images and Kubernetes configurations

**Rationale**:
- Industry trend toward containers
- Enables cloud-native deployments
- Consistent environments

**Consequences**:
- ✅ Cloud-portable
- ✅ DevOps-friendly
- ❌ Additional maintenance burden
- ❌ Requires container expertise

## Official References

- [OFBiz Deployment Guide](https://cwiki.apache.org/confluence/display/OFBIZ/Deployment)
- [OFBiz Docker Documentation](https://github.com/apache/ofbiz-framework/blob/trunk/DOCKER.adoc)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## Related Topics

- [Runtime Architecture](../06-runtime-architecture/README.md) - How OFBiz operates at runtime
- [Performance Characteristics](../09-quality-attributes/performance-characteristics.md) - Performance optimization
- [Reliability Patterns](../09-quality-attributes/reliability-patterns.md) - High availability patterns
- [JVM Tuning](../06-runtime-architecture/jvm-tuning.md) - JVM optimization for production

---

**Previous**: [Modular Architecture](modular-architecture.md)  
**Next**: [Technology Stack](technology-stack.md)  
**Up**: [System Overview](README.md)
