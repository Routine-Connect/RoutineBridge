package com.routinebridge.dev.routinebridge.controller;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@Api(tags = "User", description = "사용자 인증 API")
public class UserController {

    @ApiOperation(value = "회원가입", notes = "이메일, 비밀번호, 닉네임으로 회원가입")
    @PostMapping("/signup")
    public void signup() {}

    @ApiOperation(value = "로그인", notes = "이메일, 비밀번호로 로그인 후 JWT 반환")
    @PostMapping("/login")
    public void login() {}

    @ApiOperation(value = "프로필 수정", notes = "닉네임, 비밀번호 수정")
    @PostMapping("/me")
    public void updateProfile() {}
}
