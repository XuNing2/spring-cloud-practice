package com.example.userservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

/**
 * 用户服务启动类
 * 
 * @EnableEurekaClient 注解启用 Eureka 客户端功能
 */
@SpringBootApplication
@EnableEurekaClient
public class UserServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
        System.out.println("用户服务启动成功！");
        System.out.println("服务端口: 8081");
        System.out.println("访问地址: http://localhost:8081");
    }

}