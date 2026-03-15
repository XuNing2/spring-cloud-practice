# Spring Cloud 配置中心使用指南

## 架构概述

本项目实现了一个完整的 Spring Cloud 配置中心，采用以下架构：

```
┌─────────────────────────────────────────────┐
│          Config Server (配置服务器)         │
│          Port: 8888                        │
│     @EnableConfigServer                     │
└─────────────────────────────────────────────┘
         ▲
         │ Git 仓库 (本地)
         │
┌─────────────────────────────────────────────┐
│       config-repo/config (配置文件)         │
│  ├── eureka-server.yml                      │
│  ├── user-service.yml                       │
│  └── api-gateway.yml                        │
└─────────────────────────────────────────────┘
         ▲
         │ 拉取配置
         │
┌─────────────────────────────────────────────┐
│          Eureka Server (服务发现)            │
│          Port: 8761                        │
│                                            │
│   - User Service (8081)                    │
│   - API Gateway (8080)                     │
│   - Config Server (8888)                   │
└─────────────────────────────────────────────┘
```

## 服务启动顺序

### 1. 启动 Eureka 服务器（必须先启）

```bash
cd eureka-server
mvn clean package -DskipTests
java -jar target/eureka-server-1.0.0.jar
```

**访问地址**: http://localhost:8761/eureka/

### 2. 启动 Config Server（配置中心）

```bash
cd config-server
mvn clean package -DskipTests
java -jar target/config-server-1.0.0.jar
```

**服务地址**: http://localhost:8888

### 3. 验证配置中心

#### 获取 Eureka 服务器配置
```bash
curl http://localhost:8888/eureka-server/default/main
```

#### 获取 User Service 配置
```bash
curl http://localhost:8888/user-service/default/main
```

#### 获取 API Gateway 配置
```bash
curl http://localhost:8888/api-gateway/default/main
```

## 配置中心 API 端点

### 获取配置

```
GET /应用名/环境/分支
GET /{name}/{profile}/{label}
```

**参数说明**：
- `name`: 应用名称（对应 spring.application.name）
- `profile`: 环境配置（默认为 default）
- `label`: Git 分支（默认为 main）

**示例**：
```bash
# 获取 user-service 的 default 环境配置
curl http://localhost:8888/user-service/default/main

# 获取 api-gateway 的生产环境配置
curl http://localhost:8888/api-gateway/prod/main

# 以 JSON 格式输出
curl http://localhost:8888/user-service/default/main | python3 -m json.tool
```

## 配置文件说明

### Config Repo 结构
```
config-repo/
└── config/
    ├── eureka-server.yml         # Eureka 服务器配置
    ├── user-service.yml          # 用户服务配置
    └── api-gateway.yml           # API 网关配置
```

### 配置文件内容

#### eureka-server.yml
- **server.port**: 8761
- **eureka.client.register-with-eureka**: false（作为服务器，不注册自己）
- **eureka.server.enable-self-preservation**: false（关闭自我保护）

#### user-service.yml
- **server.port**: 8081
- **spring.datasource**: H2 数据库配置
- **eureka.client.register-with-eureka**: true（自动注册到 Eureka）
- **spring.jpa.hibernate.ddl-auto**: update（自动更新数据库）

#### api-gateway.yml
- **server.port**: 8080
- **spring.cloud.gateway.routes**: 路由配置
- **eureka.client.register-with-eureka**: true（自动注册到 Eureka）

## 客户端配置

### bootstrap.yml 配置

所有客户端应用都需要在 `src/main/resources/bootstrap.yml` 中配置：

```yaml
spring:
  cloud:
    config:
      uri: http://localhost:8888          # Config Server 地址
      name: application-name              # 应用名称
      profile: default                    # 环境配置
      label: main                         # Git 分支
```

### 客户端依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

## 配置刷新

### 手动刷新

在 application.yml 中暴露 refresh 端点：
```yaml
management:
  endpoints:
    web:
      exposure:
        include: refresh,health,info
```

然后调用刷新：
```bash
curl -X POST http://localhost:8081/actuator/refresh
```

### 自动刷新（使用 Bus）

> 需要额外配置 Spring Cloud Bus（RabbitMQ 或 Kafka）

## 常见问题

### 1. 配置无法加载

**检查清单**:
1. Eureka 服务器是否已启动 ✓
2. Config Server 是否已启动 ✓
3. bootstrap.yml 中的 `config.uri` 是否正确
4. 配置文件名称是否与 `config.name` 匹配

### 2. 获取不到配置

```bash
# 检查 config-repo 是否是 Git 仓库
cd config-repo && git status

# 确保配置文件已提交到 Git
git log config/eureka-server.yml
```

### 3. 应用启动失败

查看应用日志中是否有关于配置获取的错误信息。通常问题在于：
- Config Server 地址不正确
- 应用名称不匹配
- Git 分支名称错误

## 高级配置

### 支持多环境

在 config-repo 中添加环境特定的配置：
```
config/
├── eureka-server.yml           # 默认配置
├── eureka-server-dev.yml       # 开发环境
├── eureka-server-prod.yml      # 生产环境
```

客户端通过设置 `profile` 来选择不同的配置：
```yaml
spring:
  cloud:
    config:
      profile: prod  # 使用生产环境配置
```

### 支持多分支

配置文件可以在不同的 Git 分支中：
```bash
# 切换到 develop 分支
git checkout -b develop
# 修改配置文件
# 推送到仓库
git push
```

客户端通过设置 `label` 来选择不同的分支：
```yaml
spring:
  cloud:
    config:
      label: develop  # 使用 develop 分支的配置
```

## 监控和管理

Config Server 暴露的管理端点：

```bash
# 健康检查
curl http://localhost:8888/actuator/health

# 应用信息
curl http://localhost:8888/actuator/info

# 刷新配置
curl -X POST http://localhost:8888/actuator/refresh

# 查看环境变量
curl http://localhost:8888/actuator/env
```

## 性能优化

### 配置缓存

Config Server 默认会缓存从 Git 拉取的配置。可以调整：

```yaml
spring:
  cloud:
    config:
      server:
        git:
          timeout: 10  # Git 操作超时时间（秒）
          clone-on-start: true  # 服务启动时克隆仓库
```

### 连接池配置

对于大量的配置请求，可以调整连接池。

## 安全建议

1. **在生产环境中**:
   - 使用远程 Git 仓库而不是本地文件系统
   - 启用 HTTP Basic Auth
   - 配置 HTTPS
   - 限制可访问的端点

2. **敏感信息**:
   - 不在配置文件中存储明文密码
   - 使用 Spring Cloud Config 的加密功能
   - 或使用专门的密钥管理服务

## 启动完整系统

```bash
# 终端 1: 启动 Eureka
cd eureka-server && java -jar target/eureka-server-1.0.0.jar

# 终端 2: 启动 Config Server
sleep 5 && cd config-server && java -jar target/config-server-1.0.0.jar

# 终端 3: 启动 User Service
sleep 10 && cd user-service && mvn spring-boot:run

# 终端 4: 启动 API Gateway
sleep 5 && cd api-gateway && mvn spring-boot:run
```

## 参考资源

- [Spring Cloud Config 官方文档](https://spring.io/projects/spring-cloud-config)
- [Spring Cloud Eureka 文档](https://spring.io/projects/spring-cloud-netflix)
- [Spring Boot Actuator](https://spring.io/projects/spring-boot#learn)

## 当前运行状态

✅ **Eureka Server** 运行中 - http://localhost:8761/eureka/
✅ **Config Server** 运行中 - http://localhost:8888
✅ **配置中心正常工作** - 所有配置文件均可正确读取

