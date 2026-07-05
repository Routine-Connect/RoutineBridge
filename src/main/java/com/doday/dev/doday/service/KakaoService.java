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

import java.util.HashMap;
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



    public Map<String, Object> kakaoLogin(String accessToken) {
        Map<String, Object> kakaoUser = getKakaoUserInfo(accessToken);
        String oauthId = String.valueOf(kakaoUser.get("id"));

        Map<String, Object> kakaoAccount = (Map<String, Object>) kakaoUser.get("kakao_account");
        if (kakaoAccount == null) {
            throw new IllegalArgumentException("카카오 계정 정보를 가져올 수 없습니다. 동의항목을 확인해주세요.");
        }

        Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
        String nickname = (String) profile.get("nickname");
        String email = kakaoAccount.containsKey("email") ? (String) kakaoAccount.get("email") : null;

        UserOAuth existingOAuth = userOAuthMapper.findByProviderAndOauthId("kakao", oauthId);
        boolean isNewUser = false;

        Long userId;

        if (existingOAuth != null) {
            // 이미 카카오로 가입한 유저 → 그대로 로그인
            userId = existingOAuth.getUserId();
        } else {
            // 신규 유저 → 이메일로 기존 계정 확인
            User existingUser = email != null ? userMapper.findByEmail(email) : null;

            if (existingUser != null) {
                // 기존 이메일 계정 있으면 연동
                userId = existingUser.getId();
            } else {
                // 완전 신규 유저 → 자동 회원가입
                User newUser = new User();
                newUser.setEmail(email != null ? email : oauthId + "@kakao.com");
                newUser.setPassword("KAKAO_OAUTH");
                newUser.setNickname(nickname);
                newUser.setGender("n");
                isNewUser = true;
                userMapper.insert(newUser);
                userId = newUser.getId();
            }

            // UserOAuth 저장 (신규 연동인 경우만)
            UserOAuth newOAuth = new UserOAuth();
            newOAuth.setUserId(userId);
            newOAuth.setProvider("kakao");
            newOAuth.setOauthId(oauthId);
            userOAuthMapper.insert(newOAuth);
        }

        User user = userMapper.findById(userId);
        String token = jwtUtil.generateToken(user.getId(), user.getEmail());

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("isNewUser", isNewUser);
        result.put("gender", user.getGender());
        return result;
    }



    private Map<String, Object> getKakaoUserInfo(String accessToken) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<Map> response = restTemplate.exchange(
                "https://kapi.kakao.com/v2/user/me",
                HttpMethod.GET, entity, Map.class
        );
        return response.getBody();
    }
}
