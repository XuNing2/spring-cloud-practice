#!/bin/bash

# Config Server 一键重启脚本
# 用法: ./restart.sh

echo "=========================================="
echo "   Config Server 一键重启脚本"
echo "=========================================="

# 相对路径设置
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
export PATH=$JAVA_HOME/bin:$PATH
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="config-server"
JAR_FILE="target/config-server-1.0.0.jar"
LOG_FILE="/tmp/config-server.log"
PORT=8888

echo ""
echo "🔍 Step 1: 检查现有进程..."
PID=$(lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null)
if [ -n "$PID" ]; then
    echo "⏹️  发现运行中的进程 (PID: $PID)，正在停止..."
    kill -9 $PID
    sleep 2
    echo "✅ 进程已停止"
else
    echo "✅ 端口 $PORT 未被占用"
fi

echo ""
echo "📦 Step 2: 编译 $SERVICE_NAME..."
cd "$SCRIPT_DIR"
mvn clean package -DskipTests -q
if [ $? -eq 0 ]; then
    echo "✅ $SERVICE_NAME 编译完成"
else
    echo "❌ $SERVICE_NAME 编译失败"
    exit 1
fi

echo ""
echo "🚀 Step 3: 启动 $SERVICE_NAME（端口 $PORT）..."
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ JAR 文件不存在: $JAR_FILE"
    exit 1
fi

java -jar "$JAR_FILE" > "$LOG_FILE" 2>&1 &
CONFIG_SERVER_PID=$!
echo "✅ $SERVICE_NAME 已启动 (PID: $CONFIG_SERVER_PID)"

echo ""
echo "⏳ 等待服务启动完成（10秒）..."
sleep 10

echo ""
echo "🔍 Step 4: 检查服务健康状态..."
HEALTH_URL="http://localhost:$PORT/actuator/health"
RESPONSE=$(curl -s "$HEALTH_URL" 2>/dev/null)

if echo "$RESPONSE" | grep -q "UP"; then
    echo "✅ $SERVICE_NAME 健康检查通过"
    echo "📝 详细信息:"
    echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
elif [ -z "$RESPONSE" ]; then
    echo "⚠️  健康检查端点未响应（可能仍在启动中）"
    echo "📝 查看日志: tail -f $LOG_FILE"
else
    echo "⚠️  服务响应状态未知"
    echo "$RESPONSE"
fi

echo ""
echo "=========================================="
echo "   重启完成！"
echo "=========================================="
echo "📝 日志文件: $LOG_FILE"
echo "🌐 服务地址: http://localhost:$PORT"
echo "💡 查看实时日志: tail -f $LOG_FILE"

