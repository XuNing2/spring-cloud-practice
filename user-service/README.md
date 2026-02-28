# User Service - 用户服务

## 项目说明

用户服务是 Spring Cloud 微服务架构中的一个基础服务，负责用户信息的管理，包括用户的创建、查询、更新、删除等操作。

## 功能特性

- 用户注册和管理
- 用户信息查询
- 用户状态管理（激活/禁用）
- RESTful API 接口
- 数据持久化（JPA + H2/MySQL）
- 服务注册与发现（Eureka）

## 项目结构

```
user-service/
├── pom.xml                           # Maven 依赖配置
├── src/main/java/                    # Java 源代码
│   └── com/example/userservice/
│       ├── UserServiceApplication.java   # 启动类
│       ├── controller/                   # 控制器层
│       │   └── UserController.java       # 用户 API 控制器
│       ├── service/                      # 服务层
│       │   └── UserService.java          # 用户业务逻辑
│       ├── repository/                   # 数据访问层
│       │   └── UserRepository.java       # 用户数据操作
│       └── entity/                       # 实体类
│           └── User.java                 # 用户实体
└── src/main/resources/               # 资源文件
    └── application.yml               # 配置文件
```

## 快速开始

### 1. 启动依赖服务

确保 Eureka Server 已经启动：
```bash
cd eureka-server
mvn spring-boot:run
```

### 2. 启动用户服务

```bash
cd user-service
mvn spring-boot:run
```

### 3. 验证服务注册

访问 Eureka 管理界面：http://localhost:8761
应该能看到 `user-service` 已注册。

## API 接口

### 用户管理

#### 创建用户
```http
POST /api/users
Content-Type: application/json

{
    "username": "john_doe",
    "password": "password123",
    "email": "john@example.com",
    "fullName": "John Doe"
}
```

#### 获取所有用户
```http
GET /api/users
```

#### 根据ID获取用户
```http
GET /api/users/{id}
```

#### 根据用户名获取用户
```http
GET /api/users/username/{username}
```

#### 更新用户
```http
PUT /api/users/{id}
Content-Type: application/json

{
    "username": "john_doe_updated",
    "email": "john_new@example.com",
    "fullName": "John Doe Updated"
}
```

#### 删除用户
```http
DELETE /api/users/{id}
```

#### 激活用户
```http
POST /api/users/{id}/activate
```

#### 禁用用户
```http
POST /api/users/{id}/deactivate
```

## 数据库配置

### 开发环境（H2 内存数据库）
- 默认使用 H2 内存数据库
- 数据在应用重启后会丢失
- 适合开发和测试

### 生产环境（MySQL）
修改 `application.yml`：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/user_db?useSSL=false&serverTimezone=UTC
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: root
    password: your_password
```

## 核心技术

### Spring Boot
- 快速开发框架
- 自动配置
- 嵌入式服务器

### Spring Data JPA
- 数据访问抽象
- 自动 SQL 生成
- 事务管理

### Eureka Client
- 服务注册
- 服务发现
- 健康检查

### Lombok
- 减少样板代码
- 自动生成 getter/setter
- 简化实体类定义

## 下一步

用户服务搭建完成后，可以继续：

1. 添加用户认证和授权
2. 实现密码加密
3. 添加数据验证
4. 集成其他微服务
5. 添加单元测试

## 常见问题

### Q: 启动失败，端口被占用
A: 修改 `application.yml` 中的 `server.port` 配置

### Q: 数据库连接失败
A: 检查数据库配置，确保数据库服务已启动

### Q: 无法注册到 Eureka
A: 检查 Eureka Server 地址配置，确保网络连通性

### Q: API 调用返回 404
A: 检查服务是否正常启动，端口是否正确