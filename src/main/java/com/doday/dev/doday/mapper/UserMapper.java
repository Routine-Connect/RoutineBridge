package com.doday.dev.doday.mapper;

import com.doday.dev.doday.domain.User;

public interface UserMapper {
    void insert(User user);
    User findByEmail(String email);
    User findById(Long id);
    void update(User user);
}
