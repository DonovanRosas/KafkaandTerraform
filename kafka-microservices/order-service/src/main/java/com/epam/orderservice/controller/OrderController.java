package com.epam.orderservice.controller;

import com.epam.domains.dto.Order;
import com.epam.domains.dto.OrderEvent;
import com.epam.orderservice.kafka.OrderProducer;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@CrossOrigin(maxAge = 3600)
@RestController
@RequestMapping("/api/v1")
public class OrderController {

    private final OrderProducer orderProducer;

    public OrderController(OrderProducer orderProducer) {
        this.orderProducer = orderProducer;
    }

    @PostMapping("/orders")
    public String placeOrder(@RequestBody Order order){
        order.setOrderId(UUID.randomUUID().toString());

        OrderEvent orderEvent = new OrderEvent();
        orderEvent.setStatus("PENDING");
        orderEvent.setMessage("order status is in pending state");
        orderEvent.setOrder(order);

        orderProducer.sendMessage(orderEvent);

        return "Order placed succesfully...";
    }
}
