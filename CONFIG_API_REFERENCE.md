# Config Center API 参考文档

## 基本信息

- **服务地址**: http://localhost:8888
- **服务类型**: Spring Cloud Config Server
- **版本**: 1.0.0
- **框架**: Spring Boot 3.4.3 + Spring Cloud 2024.0.0

## 核心 API 端点

### 1. 获取配置 (GET)

#### 请求格式
```
GET /{name}/{profile}/{label}
GET /{name}/{profile}
GET /{name}
```

#### 参数说明

| 参数 | 类型 | 必需 | 说明 | 默认值 |
|------|------|------|------|--------|
| name | String | ✓ | 应用名称 | - |
| profile | String | ✗ | 环境配置 | default |
| label | String | ✗ | Git 分支 | main |

#### 请求示例

```bash
# 获取 user-service 的 default 环境配置
curl http://localhost:8888/user-service/default/main

# 获取 user-service 的生产环境配置
curl http://localhost:8888/user-service/prod/main

# 获取 eureka-server 的所有配置
curl http://localhost:8888/eureka-server

# 获取 api-gateway 的 develop 分支配置
curl http://localhost:8888/api-gateway/default/develop
```

#### 成功响应 (200 OK)

```json
{
  "name": "user-service",
  "profiles": ["default"],
  "label": "main",
  "version": "73a4dcc7fb590a4d5abd7b968ef5863b9a11e307",
  "state": "",
  "propertySources": [
    {
      "name": "file:///path/to/config-repo/config/user-service.yml",
      "source": {
        "server.port": 8081,
        "spring.application.name": "user-service",
        "spring.datasource.url": "jdbc:h2:file:./data/h2db",
        ...
      }
    }
  ]
}
```

#### 失败响应 (404 Not Found)

```json
{
  "status": 404,
  "error": "Not Found",
  "message": "Not found: application-name/default/main"
}
```

---

## 健康检查 API

### 2. 健康状态 (GET)

```bash
GET /actuator/health
```

#### 请求示例
```bash
curl http://localhost:8888/actuator/health
```

#### 响应示例
```json
{
  "status": "UP",
  "components": {
    "diskSpace": {
      "status": "UP",
      "details": {
        "status": "UP",
        "total": 1000000000000,
        "free": 500000000000,
        "threshold": 10485760,
        "exists": true
      }
    },
    "livenessState": {
      "status": "UP"
    },
    "readinessState": {
      "status": "UP"
    }
  }
}
```

---

## 管理端点

### 3. 应用信息 (GET)

```bash
GET /actuator/info
```

#### 响应示例
```json
{
  "app": {
    "name": "Config Server",
    "description": "Spring Cloud Config Server",
    "encoding": "UTF-8",
    "java": {
      "version": "21"
    }
  }
}
```

### 4. 刷新配置 (POST)

```bash
POST /actuator/refresh
```

#### 请求示例
```bash
curl -X POST http://localhost:8888/actuator/refresh
```

#### 响应示例
```json
["config.client.version"]
```

### 5. 查看环境变量 (GET)

```bash
GET /actuator/env
```

#### 请求示例
```bash
curl http://localhost:8888/actuator/env
```

### 6. 查看特定环境变量 (GET)

```bash
GET /actuator/env/{property}
```

#### 请求示例
```bash
curl http://localhost:8888/actuator/env/server.port
```

---

## 现有配置应用

### Eureka Server (`eureka-server`)

#### 配置获取
```bash
curl http://localhost:8888/eureka-server/default/main
```

#### 主要配置项
- **server.port**: 8761
- **eureka.client.register-with-eureka**: false
- **eureka.client.fetch-registry**: false
- **eureka.server.enable-self-preservation**: false
- **eureka.server.eviction-interval-timer-in-ms**: 2000

---

### User Service (`user-service`)

#### 配置获取
```bash
curl http://localhost:8888/user-service/default/main
```

#### 主要配置项
- **server.port**: 8081
- **spring.datasource.url**: jdbc:h2:file:./data/h2db
- **spring.jpa.hibernate.ddl-auto**: update
- **eureka.client.register-with-eureka**: true
- **eureka.client.service-url.defaultZone**: http://localhost:8761/eureka/

---

### API Gateway (`api-gateway`)

#### 配置获取
```bash
curl http://localhost:8888/api-gateway/default/main
```

#### 主要配置项
- **server.port**: 8080
- **spring.cloud.gateway.routes**: 
  - user-service → /user-service/**
- **eureka.client.register-with-eureka**: true
- **eureka.client.service-url.defaultZone**: http://localhost:8761/eureka/

---

## 客户端集成

### 添加依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

### bootstrap.yml 配置

```yaml
spring:
  cloud:
    config:
      uri: http://localhost:8888
      name: your-application-name
      profile: default
      label: main
```

### 读取配置值

```java
@RestController
public class ConfigController {
    
    @Value("${server.port}")
    private int serverPort;
    
    @GetMapping("/config")
    public Map<String, Object> getConfig() {
        return Map.of("port", serverPort);
    }
}
```

---

## 配置刷新

### 使用 @RefreshScope 注解

```java
@Service
@RefreshScope
public class ConfigService {
    
    @Value("${app.version}")
    private String version;
    
    public String getVersion() {
        return version;
    }
}
```

### 刷新配置

```bash
# 调用刷新端点
curl -X POST http://localhost:localhost:8081/actuator/refresh

# 或批量刷新（需要配置 Bus）
curl -X POST http://localhost:8888/actuator/bus-refresh
```

---

## 错误处理

### 常见错误码

| 状态码 | 错误 | 原因 | 解决方案 |
|--------|------|------|--------|
| 200 | OK | 配置获取成功 | - |
| 404 | Not Found | 配置文件不存在 | 检查应用名称是否正确 |
| 400 | Bad Request | 请求参数不正确 | 检查参数格式 |
| 500 | Server Error | 服务器错误 | 查看服务器日志 |

### 调试建议

```bash
# 查看健康状态
curl http://localhost:8888/actuator/health

# 查看所有暴露的端点
curl http://localhost:8888/actuator

# 查看启动日志
tail -f /tmp/config-server.log

# 测试 Git 连接
cd /path/to/config-repo && git status
```

---

## 性能优化

### 缓存策略

Config Server 默认启用缓存。可以通过以下配置调整：

```yaml
spring:
  cloud:
    config:
      server:
        git:
          timeout: 10
          clone-on-start: true
```

### 连接超时

```bash
# 增加超时时间以处理大型配置库
curl --connect-timeout 30 http://localhost:8888/user-service/default/main
```

---

## 安全最佳实践

### 1. 启用 HTTP Basic Auth（生产环境）

```yaml
spring:
  security:
    user:
      name: admin
      password: password123
```

### 2. HTTPS 配置

```yaml
server:
  ssl:
    key-store: classpath:keystore.p12
    key-store-type: PKCS12
    key-store-password: password
```

### 3. 限制端点访问

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,refresh  # 只暴露必要的端点
      base-path: /management
```

### 4. 加密敏感配置

```bash
# 使用对称加密
curl -X POST http://localhost:8888/encrypt \
  -d 'my-secret-password'

# 使用非对称加密
# 配置公钥/私钥对
```

---

## 故障排查

### 连接失败

```bash
# 检查服务是否运行
curl -I http://localhost:8888

# 检查防火墙
netstat -an | grep 8888

# 查看服务日志
tail -50 /tmp/config-server.log
```

### 配置未更新

```bash
# 清除 Git 缓存
curl -X DELETE http://localhost:8888/actuator/refresh

# 重新启动服务
kill <PID> && java -jar target/config-server-1.0.0.jar
```

### 性能缓慢

```bash
# 检查磁盘空间
df -h

# 检查 Git 操作
git log --oneline | head

# 调整超时时间
# 修改 application.yml 中的 timeout 参数
```

---

## 相关文档

- [CONFIG_CENTER_README.md](./CONFIG_CENTER_README.md) - 配置中心完整指南
- [Spring Cloud Config 官方文档](https://spring.io/projects/spring-cloud-config)
- [Spring Boot Actuator 文档](https://spring.io/projects/spring-boot#learn)

---

## 支持的格式

### JSON 格式
```bash
curl -H "Accept: application/json" http://localhost:8888/user-service/default/main
```

### YAML 格式
```bash
curl -H "Accept: application/yaml" http://localhost:8888/user-service/default/main
```

### Properties 格式
```bash
curl -H "Accept: application/properties" http://localhost:8888/user-service/default/main
```

---

## 版本信息

| 组件 | 版本 |
|------|------|
| Spring Boot | 3.4.3 |
| Spring Cloud | 2024.0.0 |
| Java | 21 |
| Maven | 3.9.x |

---

**最后更新**: 2026-03-15

