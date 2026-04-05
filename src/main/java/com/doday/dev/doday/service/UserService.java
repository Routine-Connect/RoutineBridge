package com.doday.dev.doday.service;

import com.doday.dev.doday.common.ErrorCode;
import com.doday.dev.doday.common.JwtUtil;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.dto.LoginRequestDto;
import com.doday.dev.doday.dto.SignupRequestDto;
import com.doday.dev.doday.dto.UpdateProfileRequestDto;
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
    public void signup(SignupRequestDto dto) {

        // 이메일 중복 체크
        User existing = userMapper.findByEmail(dto.getEmail());
        if (existing != null) {
            throw new IllegalArgumentException(ErrorCode.EMAIL_DUPLICATED.getMessage());
        }

        User user = new User();
        user.setEmail(dto.getEmail());
        user.setPassword(encoder.encode(dto.getPassword()));
        user.setNickname(dto.getNickname());
        user.setGender(dto.getGender());
        userMapper.insert(user);
    }

    // 로그인
    public String login(LoginRequestDto dto) {
        User existing = userMapper.findByEmail(dto.getEmail());
        if (existing == null) {
            throw new IllegalArgumentException(ErrorCode.USER_NOT_FOUND.getMessage());
        }

        if (!encoder.matches(dto.getPassword(), existing.getPassword())) {
            throw new IllegalArgumentException(ErrorCode.INVALID_PASSWORD.getMessage());
        }
        return jwtUtil.generateToken(existing.getId(), existing.getEmail());
    }

    // 프로필 수정
    public void updateProfile(Long userId, UpdateProfileRequestDto dto) {
        User existing = userMapper.findById(userId);
        if (existing == null) {
            throw new IllegalArgumentException(ErrorCode.USER_NOT_FOUND.getMessage());
        }
        existing.setNickname(dto.getNickname());

        if (dto.getPassword() != null && !dto.getPassword().isEmpty()) {
            existing.setPassword(encoder.encode(dto.getPassword()));
        }
        userMapper.update(existing);
    }
}
