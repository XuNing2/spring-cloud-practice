# 🚀 配置中心快速开始指南

## 5 分钟快速启动

### 1️⃣ 一键启动（推荐）

```bash
cd /Users/xuning/Projects/spring-cloud-practice
./start-config-center.sh
```

该脚本会自动：
- ✅ 编译 Eureka 服务器
- ✅ 编译 Config 服务器
- ✅ 启动 Eureka 服务器（端口 8761）
- ✅ 启动 Config 服务器（端口 8888）

---

### 2️⃣ 手动启动

#### 步骤 1: 启动 Eureka Server

```bash
cd eureka-server
mvn clean package -DskipTests
java -jar target/eureka-server-1.0.0.jar
```

✅ Eureka 控制台: http://localhost:8761/eureka/

#### 步骤 2: 启动 Config Server

在新的终端窗口中：

```bash
cd config-server
mvn clean package -DskipTests
java -jar target/config-server-1.0.0.jar
```

✅ Config Server: http://localhost:8888

---

### 3️⃣ 验证配置中心

```bash
# 获取 User Service 配置
curl http://localhost:8888/user-service/default/main | python3 -m json.tool

# 获取 API Gateway 配置
curl http://localhost:8888/api-gateway/default/main | python3 -m json.tool

# 获取 Eureka Server 配置
curl http://localhost:8888/eureka-server/default/main | python3 -m json.tool
```

---

## 📊 系统架构

```
┌──────────────────────────────────────────────┐
│                Config Server                 │
│  Spring Cloud Config Server (Port: 8888)    │
└────────────────────┬─────────────────────────┘
                     │
                     ↓ (Git)
┌──────────────────────────────────────────────┐
│              Config Repository               │
│         /config-repo/config/*.yml            │
│  ├── eureka-server.yml                       │
│  ├── user-service.yml                        │
│  └── api-gateway.yml                         │
└──────────────────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         ↓           ↓           ↓
   ┌─────────┐ ┌─────────┐ ┌──────────┐
   │ Eureka  │ │  User   │ │   API    │
   │ Server  │ │ Service │ │ Gateway  │
   │ 8761    │ │ 8081    │ │ 8080     │
   └─────────┘ └─────────┘ └──────────┘
```

---

## 🔧 核心概念

### Config Server
- **角色**: 中央配置管理服务
- **端口**: 8888
- **职责**: 从 Git 仓库读取配置文件，向客户端提供配置

### Config Repository
- **位置**: `/config-repo/config/`
- **存储**: Git 仓库中的配置文件
- **格式**: YAML 配置文件

### 客户端
- **应用**: eureka-server, user-service, api-gateway
- **配置**: `bootstrap.yml` 中指定 Config Server 地址
- **启动流程**: 先从 Config Server 获取配置，再启动应用

---

## 📝 配置文件说明

### eureka-server.yml
服务注册中心配置，其他服务通过此服务发现彼此。

```yaml
server:
  port: 8761
eureka:
  server:
    enable-self-preservation: false  # 生产建议开启
```

### user-service.yml
用户服务配置，包含数据库和 Eureka 客户端设置。

```yaml
server:
  port: 8081
spring:
  datasource:
    url: jdbc:h2:file:./data/h2db
```

### api-gateway.yml
API 网关配置，定义路由规则。

```yaml
server:
  port: 8080
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service
```

---

## 🎯 常用命令

### 获取配置

```bash
# 基本格式
curl http://localhost:8888/{应用名}/{环境}/{分支}

# 示例
curl http://localhost:8888/user-service/default/main
curl http://localhost:8888/api-gateway/prod/main
curl http://localhost:8888/eureka-server/default/main

# JSON 格式输出
curl http://localhost:8888/user-service/default/main | python3 -m json.tool
```

### 健康检查

```bash
# 配置中心健康状态
curl http://localhost:8888/actuator/health

# 查看所有端点
curl http://localhost:8888/actuator
```

### 刷新配置

```bash
# 刷新 Config Server 缓存
curl -X POST http://localhost:8888/actuator/refresh
```

---

## 🐛 常见问题与解决

### ❌ Config Server 连接失败

```bash
# 检查 Eureka 是否已启动
curl http://localhost:8761/eureka/apps

# 检查 Config Server 是否已启动
curl http://localhost:8888/actuator/health

# 查看日志
tail -50 /tmp/config-server.log
```

### ❌ 无法获取配置

```bash
# 检查应用名称是否正确
# 应用名称必须与 spring.cloud.config.name 和配置文件名匹配

# 验证配置文件存在
ls /path/to/config-repo/config/

# 查看 Git 状态
cd /path/to/config-repo && git log
```

### ❌ 配置未更新

```bash
# 刷新 Config Server 缓存
curl -X POST http://localhost:8888/actuator/refresh

# 重启应用 (如果使用 @RefreshScope)
curl -X POST http://localhost:8081/actuator/refresh
```

---

## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [CONFIG_CENTER_README.md](./CONFIG_CENTER_README.md) | 完整的架构和配置指南 |
| [CONFIG_API_REFERENCE.md](./CONFIG_API_REFERENCE.md) | 详细的 API 参考文档 |
| [QUICKSTART.md](./QUICKSTART.md) | 本文件 - 快速开始 |

---

## 🔗 服务端点

| 服务 | 地址 | 说明 |
|------|------|------|
| Eureka | http://localhost:8761/ | 服务注册中心 UI |
| Config Server | http://localhost:8888 | 配置中心 API |
| User Service | http://localhost:8081 | 用户服务 |
| API Gateway | http://localhost:8080 | API 网关 |

---

## 🎓 学习路径

### 初级
1. 启动 Eureka 和 Config Server
2. 使用 curl 获取各个应用的配置
3. 理解配置文件与应用名称的映射关系

### 中级
4. 修改 Config 文件，观察配置变化
5. 启动 User Service，观察配置加载过程
6. 使用 @Value 注解在应用中读取配置

### 高级
7. 实现 @RefreshScope 注解实现热更新
8. 配置 Spring Cloud Bus 实现配置批量推送
9. 搭建 GitHub 远程仓库实现团队协作

---

## 💡 最佳实践

### 1. 分离环境配置

```
config/
├── application.yml           # 通用配置
├── application-dev.yml       # 开发环境
├── application-prod.yml      # 生产环境
├── user-service.yml          # 通用应用配置
├── user-service-prod.yml     # 应用生产配置
```

### 2. 版本控制

```bash
# 所有配置文件都应该在 Git 中版本控制
git add config/
git commit -m "Update configuration"
git tag -a v1.0.0 -m "Release version 1.0.0"
```

### 3. 敏感信息保护

```bash
# ❌ 不要在配置文件中存储密码
password: admin123

# ✅ 使用环境变量或密钥管理服务
password: ${DB_PASSWORD}
```

### 4. 配置备份

```bash
# 定期备份配置仓库
git remote add backup /path/to/backup/repo
git push backup main
```

---

## 🚨 关闭服务

```bash
# 获取服务的进程 ID
ps aux | grep java

# 关闭特定服务
kill -9 <PID>

# 或使用启动脚本输出的 PID
kill 12345 12346
```

---

## 📞 支持和反馈

- 查看 Spring Cloud 官方文档: https://spring.io/projects/spring-cloud-config
- 查看项目 README: [README.md](./README.md)
- 查看完整指南: [CONFIG_CENTER_README.md](./CONFIG_CENTER_README.md)

---

## ✅ 验证清单

启动完成后，请验证以下项目：

- [ ] Eureka Server 运行在 http://localhost:8761
- [ ] Config Server 运行在 http://localhost:8888
- [ ] 能够获取 eureka-server 配置
- [ ] 能够获取 user-service 配置
- [ ] 能够获取 api-gateway 配置
- [ ] /actuator/health 返回 UP
- [ ] 所有测试通过

```bash
# 运行完整测试
./test-config-center.sh
```

---

**恭喜！🎉 你已经拥有一个完整运行的 Spring Cloud 配置中心！**

接下来可以：
1. 修改配置文件，测试配置变化
2. 启动其他微服务，观察配置加载
3. 实现配置热更新功能
4. 迁移到远程 Git 仓库

---

最后更新: 2026-03-15

