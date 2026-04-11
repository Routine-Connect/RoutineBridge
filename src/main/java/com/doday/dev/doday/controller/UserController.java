package com.doday.dev.doday.controller;

import com.doday.dev.doday.common.ApiResponse;
import com.doday.dev.doday.dto.LoginRequestDto;
import com.doday.dev.doday.dto.SignupRequestDto;
import com.doday.dev.doday.dto.UpdateProfileRequestDto;
import com.doday.dev.doday.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

@RestController
@RequestMapping("/api/users")
@Api(tags = "User", description = "사용자 인증 API")
public class UserController {

    @Autowired
    UserService userService;

    @ApiOperation(value = "회원가입", notes = "이메일, 비밀번호, 닉네임으로 회원가입")
    @PostMapping("/signup")
    public ApiResponse<Void> signup(@RequestBody @Valid SignupRequestDto dto) {
        userService.signup(dto);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "로그인", notes = "이메일, 비밀번호로 로그인 후 JWT 반환")
    @PostMapping("/login")
    public ApiResponse<String> login(@RequestBody @Valid LoginRequestDto dto) {
        String token = userService.login(dto);
        return ApiResponse.success(token);
    }

    @ApiOperation(value = "프로필 수정", notes = "닉네임, 비밀번호 수정")
    @PostMapping("/me")
    public ApiResponse<Void> updateProfile(@RequestBody @Valid UpdateProfileRequestDto dto,
                                           HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        userService.updateProfile(userId, dto);
        return ApiResponse.success(null);
    }

    @ApiOperation(value = "프로필 이미지 업로드", notes = "프로필 이미지 업로드")
    @PostMapping("/me/image")
    public ApiResponse<String> uploadImage(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String imageUrl = userService.uploadProfileImage(userId, file);
        return ApiResponse.success(imageUrl);
    }
}
