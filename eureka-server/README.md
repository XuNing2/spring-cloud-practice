# Eureka Server - 服务注册中心

## 项目说明

Eureka Server 是 Spring Cloud Netflix Eureka 的服务注册中心实现，用于微服务架构中的服务发现和注册。

## 功能特性

- 服务注册与发现
- 服务健康检查
- 服务元数据管理
- 自我保护机制
- 高可用集群支持

## 项目结构

```
eureka-server/
├── pom.xml                           # Maven 依赖配置
├── src/main/java/                    # Java 源代码
│   └── com/example/eurekaserver/
│       └── EurekaServerApplication.java  # 启动类
└── src/main/resources/               # 资源文件
    └── application.yml               # 配置文件
```

## 快速开始

### 1. 启动 Eureka Server

```bash
cd eureka-server
mvn spring-boot:run
```

### 2. 访问管理界面

启动成功后，访问 http://localhost:8761

可以看到 Eureka 的管理界面，目前没有注册的服务。

## 配置说明

### application.yml 配置项

- `server.port`: 服务端口，默认 8761
- `spring.application.name`: 应用名称
- `eureka.client.register-with-eureka`: 是否注册到 Eureka
- `eureka.client.fetch-registry`: 是否获取注册信息
- `eureka.client.service-url.defaultZone`: Eureka 服务地址
- `eureka.server.enable-self-preservation`: 是否启用自我保护
- `eureka.server.eviction-interval-timer-in-ms`: 清理间隔

## 核心注解

### @EnableEurekaServer

- 标注在启动类上
- 启用 Eureka Server 功能
- 自动配置 Eureka 相关组件

## 工作原理

1. **服务注册**: 微服务启动时向 Eureka Server 注册自己的信息
2. **服务发现**: 微服务从 Eureka Server 获取其他服务的信息
3. **健康检查**: Eureka Server 定期检查服务的健康状态
4. **服务剔除**: 不健康的服务会被从注册表中移除

## 下一步

搭建完 Eureka Server 后，可以继续：

1. 创建用户服务并注册到 Eureka
2. 配置 Eureka 集群实现高可用
3. 添加服务间通信功能
4. 实现负载均衡

## 常见问题

### Q: 启动失败，端口被占用
A: 修改 `application.yml` 中的 `server.port` 配置

### Q: 无法访问管理界面
A: 检查防火墙设置，确保 8761 端口可访问

### Q: 服务注册失败
A: 检查服务的 Eureka 配置，确保 `defaultZone` 地址正确