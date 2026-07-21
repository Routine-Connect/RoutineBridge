package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.common.ErrorCode;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.mapper.UserMapper;
import com.doday.dev.doday.service.EmailService;
import com.doday.dev.doday.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth/email")
@Api(tags = "Email", description = "이메일 인증 API")
public class EmailController {

    @Autowired
    private EmailService emailService;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserService userService;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @ApiOperation(value = "인증코드 발송", notes = "이메일로 인증코드 발송")
    @PostMapping("/send")
    public ApiResponse<Void> sendCode(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        emailService.sendVerificationCode(email);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "인증코드 확인", notes = "인증코드 검증")
    @PostMapping("/verify")
    public ApiResponse<Void> verifyCode(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String code = body.get("code");
        boolean result = emailService.verifyCode(email, code);
        if (!result) {
            return ApiResponse.fail(ErrorCode.INVALID_INPUT.getCode(), "인증코드가 올바르지 않거나 만료됐습니다.");
        }
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "비밀번호 찾기", notes = "이메일로 임시 비밀번호 발송")
    @PostMapping("/password/reset")
    public ApiResponse<Void> resetPassword(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        User user = userMapper.findByEmail(email);
        if (user == null) {
            return ApiResponse.fail(ErrorCode.USER_NOT_FOUND.getCode(), ErrorCode.USER_NOT_FOUND.getMessage());
        }
        String tempPassword = emailService.sendTempPassword(email);
        user.setPassword(passwordEncoder.encode(tempPassword));
        userMapper.update(user);
        return ApiResponse.success(null);
    }
}
