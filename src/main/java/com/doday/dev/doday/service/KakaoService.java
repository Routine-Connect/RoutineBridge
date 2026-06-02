package com.doday.dev.doday.service;

import com.doday.dev.doday.common.JwtUtil;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.domain.UserOAuth;
import com.doday.dev.doday.mapper.UserMapper;
import com.doday.dev.doday.mapper.UserOAuthMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
public class KakaoService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserOAuthMapper userOAuthMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${kakao.client.id}")
    private String kakaoClientId;



    public String kakaoLogin(String accessToken) {
        Map<String, Object> kakaoUser = getKakaoUserInfo(accessToken);
        String oauthId = String.valueOf(kakaoUser.get("id"));

        Map<String, Object> kakaoAccount = (Map<String, Object>)  kakaoUser.get("kakao_account");
        Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");

        String nickname = (String) profile.get("nickname");
        String email = kakaoAccount.containsKey("email") ? (String) kakaoAccount.get("email") : null;

        // 기존 OAuth 계정 확인
        UserOAuth existingOAuth = userOAuthMapper.findByProviderAndOauthId("kakao", oauthId);

        Long userId = null;

        if (existingOAuth != null) {
            // 이미 카카오로 가입한 유저 → 로그인
            User existingUser = email != null ? userMapper.findByEmail(email) : null;

            if (existingUser != null) {
                // 기존 이메일 계정 있으면 연동
                userId = existingUser.getId();
            } else {
                // 완전 신규 유저 → 자동 회원 가입
                User newUser = new User();
                newUser.setEmail(email != null ? email : oauthId + "@kakao.com");
                newUser.setPassword("KAKAO_OAUTH");
                newUser.setNickname(nickname);
                newUser.setGender("m");
                userMapper.insert(newUser);
                userId = newUser.getId();
            }

            // userOAuth 저장
            UserOAuth newOAuth = new UserOAuth();
            newOAuth.setUserId(userId);
            newOAuth.setProvider("kakao");
            newOAuth.setOauthId(oauthId);
            userOAuthMapper.insert(newOAuth);
        }

        // JWT 발급
        User user = userMapper.findById(userId);
        return jwtUtil.generateToken(user.getId(), user.getEmail());
    }



    private Map<String, Object> getKakaoUserInfo(String accessToken) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<Map> response = restTemplate.exchange(
                "https://kapi.kakao.com",
                HttpMethod.GET, entity, Map.class
        );
        return response.getBody();
    }
}
