package com.routinebridge.dev.routinebridge.mapper;

import com.routinebridge.dev.routinebridge.domain.User;

public interface UserMapper {
    void insert(User user);
    User findByEmail(String email);
    User findById(Long id);
    void update(User user);
}
