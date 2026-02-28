# Spring Cloud 实践学习指南

## 学习目标

通过实际项目来掌握 Spring Cloud 微服务架构的核心组件和最佳实践。

## 学习路径

### 第一阶段：基础环境搭建

1. **开发环境准备**
   - JDK 8+ 或 JDK 11
   - Maven 3.6+
   - Spring Boot 2.7.x
   - Spring Cloud 2021.x

2. **项目结构设计**
   ```
   spring-cloud-practice/
   ├── eureka-server/          # 服务注册中心
   ├── config-server/          # 配置中心
   ├── gateway-server/         # API网关
   ├── user-service/           # 用户服务
   ├── order-service/          # 订单服务
   ├── product-service/        # 商品服务
   └── common/                 # 公共模块
   ```

### 第二阶段：核心组件实践

#### 1. 服务注册与发现 (Eureka)
- 搭建 Eureka 服务注册中心
- 服务注册与发现机制
- 服务健康检查

#### 2. 配置中心 (Spring Cloud Config)
- 配置文件集中管理
- 环境隔离 (dev/test/prod)
- 动态配置刷新

#### 3. API 网关 (Spring Cloud Gateway)
- 路由配置
- 负载均衡
- 限流和熔断
- 请求过滤

#### 4. 服务间通信
- RestTemplate + Ribbon
- Feign 声明式调用
- 服务降级和熔断 (Hystrix/Resilience4j)

#### 5. 分布式链路追踪
- Sleuth + Zipkin
- 请求链路追踪
- 性能监控

### 第三阶段：进阶功能

#### 1. 消息驱动 (Spring Cloud Stream)
- 消息队列集成
- 事件驱动架构

#### 2. 安全认证
- OAuth2 + JWT
- 微服务安全

#### 3. 容器化部署
- Docker 容器化
- Docker Compose 编排

## 实践项目：电商系统

### 项目架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Gateway       │    │   Config        │    │   Eureka        │
│   (API网关)      │    │   (配置中心)     │    │   (注册中心)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────┬───────────────┼───────────────┬─────────────┐
    │             │               │               │             │
┌─────────┐  ┌─────────┐    ┌─────────┐    ┌─────────┐  ┌─────────┐
│UserSvc  │  │OrderSvc │    │Product  │    │Zipkin   │  │RabbitMQ │
│(用户服务)│  │(订单服务)│    │(商品服务)│    │(链路追踪)│  │(消息队列)│
└─────────┘  └─────────┘    └─────────┘    └─────────┘  └─────────┘
```

### 业务场景
1. 用户注册和登录
2. 商品浏览和管理
3. 下单和订单查询
4. 库存管理
5. 订单状态流转

## 学习资源

### 官方文档
- [Spring Cloud 官方文档](https://spring.io/projects/spring-cloud)
- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)

### 推荐书籍
- 《Spring Cloud 微服务实战》- 翟永超
- 《Spring 微服务实战》- John Carnell

### 在线教程
- Spring 官方教程
- B 站相关视频教程
- GitHub 开源项目参考

### 实用工具
- [Spring Initializr](https://start.spring.io/) - 项目脚手架
- [Spring Cloud 版本兼容性](https://spring.io/projects/spring-cloud#learn) - 版本选择
- [Docker Hub](https://hub.docker.com/) - 容器镜像

## 学习建议

1. **循序渐进**：先理解单体架构，再学习微服务
2. **动手实践**：每个组件都要亲自搭建和测试
3. **理解原理**：不仅会用，还要理解底层机制
4. **关注生态**：了解 Spring Cloud 生态的其他组件
5. **性能优化**：学习微服务的性能调优和监控
6. **生产部署**：了解容器化和 CI/CD 流程

## 下一步

建议从搭建第一个 Eureka 服务注册中心开始，逐步添加其他组件。每个阶段完成后，都要进行充分的测试和验证。