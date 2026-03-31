package com.routinebridge.dev.routinebridge.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class ApiTestController {

    @GetMapping("/api/check")
    public Map<String, Object> connectionCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "서버 연결 성공!");
        response.put("version", "1.0.0");
        return response;
    }
}
