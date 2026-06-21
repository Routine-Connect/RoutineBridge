package com.doday.dev.doday.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class LoginAttemptSerivce {

    private static final int MAX_ATTEMPTS = 5;

    // 실패 횟수 캐시 (10분 후 자동 만료)
    private final Cache<String, Integer> attemptCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .build();

    public void loginFailed(String email) {
        int attempts = attemptCache.get(email, k -> 0);
        attemptCache.put(email, attempts + 1);
    }

    public void loginSucceeded(String email) {
        attemptCache.invalidate(email);
    }

    public boolean isBlocked(String email) {
        Integer attempts = attemptCache.getIfPresent(email);
        return attempts != null && attempts >= MAX_ATTEMPTS;
    }

    public int getRemainingAttempts(String email) {
        Integer attempts = attemptCache.getIfPresent(email);
        return MAX_ATTEMPTS - (attempts == null ? 0 : attempts);
    }
}
