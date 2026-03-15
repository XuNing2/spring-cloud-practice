#!/bin/bash

# Spring Cloud 配置中心快速启动脚本
# 用法: ./start-config-center.sh

echo "==========================================
   Spring Cloud 配置中心启动脚本
==========================================

export JAVA_HOME=/opt/homebrew/opt/openjdk@21
export PATH=$JAVA_HOME/bin:$PATH
PROJECT_HOME="/Users/xuning/Projects/spring-cloud-practice"

# 检查项目目录
if [ ! -d "$PROJECT_HOME" ]; then
    echo "❌ 项目目录不存在: $PROJECT_HOME"
    exit 1
fi

echo ""
echo "📦 Step 1: 编译 Eureka 服务器..."
cd "$PROJECT_HOME/eureka-server"
mvn clean package -DskipTests -q
if [ $? -eq 0 ]; then
    echo "✅ Eureka 服务器编译完成"
else
    echo "❌ Eureka 服务器编译失败"
    exit 1
fi

echo ""
echo "📦 Step 2: 编译 Config 服务器..."
cd "$PROJECT_HOME/config-server"
mvn clean package -DskipTests -q
if [ $? -eq 0 ]; then
    echo "✅ Config 服务器编译完成"
else
    echo "❌ Config 服务器编译失败"
    exit 1
fi

echo ""
echo "🚀 Step 3: 启动 Eureka 服务器（端口 8761）..."
cd "$PROJECT_HOME/eureka-server"
java -jar target/eureka-server-1.0.0.jar > /tmp/eureka-server.log 2>&1 &
EUREKA_PID=$!
echo "✅ Eureka 服务器已启动 (PID: $EUREKA_PID)"

echo ""
echo "⏳ 等待 Eureka 启动完成（5秒）..."
sleep 5

echo ""
echo "🚀 Step 4: 启动 Config 服务器（端口 8888）..."
cd "$PROJECT_HOME/config-server"
java -jar target/config-server-1.0.0.jar > /tmp/config-server.log 2>&1 &
CONFIG_PID=$!
echo "✅ Config 服务器已启动 (PID: $CONFIG_PID)"

echo ""
echo "⏳ 等待 Config 启动完成（5秒）..."
sleep 5

echo ""
echo "==========================================
   配置中心启动完成！
=========================================="
echo ""
echo "📍 服务地址："
echo "   • Eureka Dashboard: http://localhost:8761/"
echo "   • Config Server: http://localhost:8888"
echo ""
echo "🔗 快速测试："
echo "   • 获取 Eureka 配置:"
echo "     curl http://localhost:8888/eureka-server/default/main"
echo ""
echo "   • 获取 User Service 配置:"
echo "     curl http://localhost:8888/user-service/default/main"
echo ""
echo "   • 获取 API Gateway 配置:"
echo "     curl http://localhost:8888/api-gateway/default/main"
echo ""
echo "📋 日志文件："
echo "   • Eureka: /tmp/eureka-server.log"
echo "   • Config: /tmp/config-server.log"
echo ""
echo "⏹️  关闭服务："
echo "   kill $EUREKA_PID $CONFIG_PID"
echo ""
echo "📚 更多信息请查看: CONFIG_CENTER_README.md"
echo ""

