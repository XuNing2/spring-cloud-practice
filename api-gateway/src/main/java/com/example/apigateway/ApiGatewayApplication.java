package com.example.apigateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

/**
 * API Gateway 启动类
 */
@SpringBootApplication
@EnableEurekaClient
public class ApiGatewayApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
        System.out.println("API Gateway 启动成功！");
        System.out.println("服务端口: 8080");
        System.out.println("访问地址: http://localhost:8080");
    }
}
