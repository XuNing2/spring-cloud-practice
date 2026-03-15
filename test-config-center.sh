#!/bin/bash

# 配置中心测试脚本
# 用法: ./test-config-center.sh

echo "==========================================
   配置中心测试脚本
=========================================="

BASE_URL="http://localhost:8888"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 函数：测试端点
test_endpoint() {
    local name=$1
    local endpoint=$2

    echo ""
    echo -e "${YELLOW}测试: $name${NC}"
    echo "端点: $endpoint"

    response=$(curl -s "$BASE_URL$endpoint")

    if echo "$response" | grep -q '"name"'; then
        echo -e "${GREEN}✅ 成功${NC}"
        echo "$response" | python3 -m json.tool 2>/dev/null | head -20
    else
        echo -e "${RED}❌ 失败${NC}"
        echo "$response"
    fi
}

echo ""
echo "检查配置中心连接状态..."
if ! curl -s "$BASE_URL/actuator/health" | grep -q "UP"; then
    echo -e "${RED}❌ Config Server 未运行在 $BASE_URL${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Config Server 连接正常${NC}"

echo ""
echo "==========================================
   获取配置文件
=========================================="

# 测试各个应用的配置
test_endpoint "Eureka Server 配置" "/eureka-server/default/main"
test_endpoint "User Service 配置" "/user-service/default/main"
test_endpoint "API Gateway 配置" "/api-gateway/default/main"

echo ""
echo "==========================================
   管理端点测试
=========================================="

echo ""
echo -e "${YELLOW}获取健康状态${NC}"
curl -s "$BASE_URL/actuator/health" | python3 -m json.tool 2>/dev/null

echo ""
echo -e "${YELLOW}获取应用信息${NC}"
curl -s "$BASE_URL/actuator/info" | python3 -m json.tool 2>/dev/null

echo ""
echo "==========================================
   测试完成！
=========================================="

