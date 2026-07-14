package com.doday.dev.doday.domain;

import lombok.Data;

@Data
public class ShareToken {
    private Long id;
    private Long userId;
    private String token;
    private String createdAt;
}
