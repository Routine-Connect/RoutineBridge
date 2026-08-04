package com.doday.dev.doday.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import javax.mail.internet.MimeMessage;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    // 인증코드 캐시 (5분 만료)
    private final Cache<String, String> emailCodeCache = Caffeine.newBuilder()
            .expireAfterWrite(5, TimeUnit.MINUTES)
            .build();

    // 인증 완료 캐시 (30분 유지)
    private final Cache<String, Boolean> verifiedCache = Caffeine.newBuilder()
            .expireAfterWrite(30, TimeUnit.MINUTES)
            .build();

    // 인증코드 발송
    public void sendVerificationCode(String email) {
        String code = generateCode();
        emailCodeCache.put(email, code);

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom("noreply@doday-quokka.co.kr");
            helper.setTo(email);
            helper.setSubject("[DoDay] 이메일 인증 코드");
            helper.setText(
                    "<div style='font-family: sans-serif; max-width: 400px; margin: 0 auto;'>" +
                            "<h2 style='color: #C49A6C;'>🐾 DoDay 이메일 인증</h2>" +
                            "<p>아래 인증 코드를 입력해주세요.</p>" +
                            "<div style='background: #F5F0E8; padding: 20px; border-radius: 8px; text-align: center;'>" +
                            "<h1 style='color: #3D2B1F; letter-spacing: 8px;'>" + code + "</h1>" +
                            "</div>" +
                            "<p style='color: #9A7B5C; font-size: 12px;'>인증 코드는 5분간 유효합니다.</p>" +
                            "</div>",
                    true
            );
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("이메일 발송에 실패했습니다: " + e.getMessage());
        }
    }

    // 인증코드 확인
    public boolean verifyCode(String email, String code) {
        String cached = emailCodeCache.getIfPresent(email);
        if (cached != null && cached.equals(code)) {
            emailCodeCache.invalidate(email);
            verifiedCache.put(email, true);
            return true;
        }
        return false;
    }

    // 인증 완료 여부 확인
    public boolean isVerified(String email) {
        return Boolean.TRUE.equals(verifiedCache.getIfPresent(email));
    }

    // 인증 완료 후 캐시 제거
    public void clearVerified(String email) {
        verifiedCache.invalidate(email);
    }

    // 임시 비밀번호 발송
    public String sendTempPassword(String email) {
        String tempPassword = generateTempPassword();

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom("Moderator@doday-quokka.co.kr");
            helper.setTo(email);
            helper.setSubject("[DoDay] 임시 비밀번호 발급");
            helper.setText(
                    "<div style='font-family: sans-serif; max-width: 400px; margin: 0 auto;'>" +
                            "<h2 style='color: #C49A6C;'>🐾 DoDay 임시 비밀번호</h2>" +
                            "<p>아래 임시 비밀번호로 로그인 후 비밀번호를 변경해주세요.</p>" +
                            "<div style='background: #F5F0E8; padding: 20px; border-radius: 8px; text-align: center;'>" +
                            "<h2 style='color: #3D2B1F; letter-spacing: 4px;'>" + tempPassword + "</h2>" +
                            "</div>" +
                            "<p style='color: #9A7B5C; font-size: 12px;'>보안을 위해 로그인 후 반드시 비밀번호를 변경해주세요.</p>" +
                            "</div>",
                    true
            );
            mailSender.send(message);
        } catch (Exception e) {
            throw new RuntimeException("이메일 발송에 실패했습니다.");
        }

        return tempPassword;
    }

    // 6자리 인증코드 생성
    private String generateCode() {
        return String.format("%06d", new Random().nextInt(999999));
    }

    // 임시 비밀번호 생성
    private String generateTempPassword() {
        String chars = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";
        StringBuilder sb = new StringBuilder();
        Random random = new Random();
        for (int i = 0; i < 10; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }


}
