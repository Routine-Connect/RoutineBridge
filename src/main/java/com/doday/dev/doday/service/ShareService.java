package com.doday.dev.doday.service;

import com.doday.dev.doday.domain.ShareToken;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.mapper.ShareTokenMapper;
import com.doday.dev.doday.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class ShareService {

    @Autowired
    private ShareTokenMapper shareTokenMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private StatsService statsService;

    @Value("${server.url}")
    private String serverUrl;

    // 공유 토큰 발급
    public String generateShareToken(Long userId) {
        ShareToken existing = shareTokenMapper.findByUserId(userId);

        if (existing != null) {
            // 이미 토큰 있으면 재발급
            String newToken = UUID.randomUUID().toString().replace("-", "");
            existing.setToken(newToken);
            shareTokenMapper.update(existing);
            return serverUrl + "/share/" + newToken;
        } else {
            // 신규 토큰 발급
            String token = UUID.randomUUID().toString().replace("-", "");
            ShareToken shareToken = new ShareToken();
            shareToken.setUserId(userId);
            shareToken.setToken(token);
            shareTokenMapper.insert(shareToken);
            return serverUrl + "/share/" + token;
        }
    }


    // 공유 페이지 데이터 조회
    public Map<String, Object> getShareData(String token) {
        ShareToken shareToken = shareTokenMapper.findByToken(token);
        if (shareToken == null) {
            throw new IllegalArgumentException("유효하지 않은 공유 링크입니다.");
        }

        Long userId = shareToken.getUserId();
        User user = userMapper.findById(userId);

        // 스트릭 데이터 가져오기
        Map<String, Object> streak = statsService.getStreak(userId);

        Map<String, Object> result = new HashMap<>();
        result.put("nickname", user.getNickname());
        result.put("profileImage", user.getProfileImage());
        result.put("currentStreak", streak.get("currentStreak"));
        result.put("longestStreak", streak.get("longestStreak"));
        result.put("totalCompleted", streak.get("totalCompleted"));
        return result;
    }
}
