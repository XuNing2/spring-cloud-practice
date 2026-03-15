package com.example.orderservice.controller;

import com.example.orderservice.entity.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/orders")
public class OrderController {

    @Autowired
    private RestTemplate restTemplate;

    @GetMapping("/{id}")
    public Order getOrder(@PathVariable Long id) {
        // 1. 模拟一个本地订单数据，假设这个订单属于 userId 为 1 的用户
        Order order = new Order(id, "ORD-2024-" + id, 1L, null);

        // 2. 关键点：使用 RestTemplate 跨服务调用
        // 因为启动类加了 @LoadBalanced，这里可以直接写服务名 "user-service"
        String userServiceUrl = "http://user-service/users/" + order.getUserId();
        
        // 发起 GET 请求
        Object user = restTemplate.getForObject(userServiceUrl, Object.class);

        // 3. 将查到的用户信息塞进订单对象
        order.setUserInfo(user);
        return order;
    }
}