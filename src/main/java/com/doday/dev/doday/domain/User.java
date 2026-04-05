package com.doday.dev.doday.domain;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class User {
    private Long id;
    private String email;
    private String password;
    private String nickname;
    private String gender;      // 'm' or 'w'
    private String createdAt;
}
