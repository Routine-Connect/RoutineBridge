package com.doday.dev.doday.domain;

import lombok.Data;

@Data
public class UserOAuth {
    private Long id;
    private Long userId;
    private String provider;
    private String oauthId;
    private String createdAt;
}
