package com.doday.dev.doday.service;

import com.doday.dev.doday.common.ErrorCode;
import com.doday.dev.doday.common.JwtUtil;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();


    // 회원가입
    public void signup(User user) {

        // 이메일 중복 체크
        User existing = userMapper.findByEmail(user.getEmail());
        if (existing != null) {
            throw new IllegalArgumentException(ErrorCode.EMAIL_DUPLICATED.getMessage());
        }

        // 비밀번호 암호화
        user.setPassword(encoder.encode(user.getPassword()));
        userMapper.insert(user);
    }

    // 로그인
    public String login(User user) {
        User existing = userMapper.findByEmail(user.getEmail());
        if (existing == null) {
            throw new IllegalArgumentException(ErrorCode.USER_NOT_FOUND.getMessage());
        }

        if (!encoder.matches(user.getPassword(), existing.getPassword())) {
            throw new IllegalArgumentException(ErrorCode.INVALID_PASSWORD.getMessage());
        }
        return jwtUtil.generateToken(existing.getId(), existing.getEmail());
    }

    // 프로필 수정
    public void updateProfile(User user) {
        User existing = userMapper.findById(user.getId());
        if (existing == null) {
            throw new IllegalArgumentException(ErrorCode.USER_NOT_FOUND.getMessage());
        }
        if (user.getPassword() != null) {
            user.setPassword(encoder.encode(user.getPassword()));
        }
        userMapper.update(user);
    }
}
