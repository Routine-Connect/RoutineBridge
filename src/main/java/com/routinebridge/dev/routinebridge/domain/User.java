package com.routinebridge.dev.routinebridge.domain;

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
    private String createdAt;
}
