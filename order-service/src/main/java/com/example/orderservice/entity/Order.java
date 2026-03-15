package com.example.orderservice.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Order {
    private Long id;
    private String orderNumber;
    private Long userId;
    private Object userInfo; // 用来存放从 user-service 查回来的数据
}