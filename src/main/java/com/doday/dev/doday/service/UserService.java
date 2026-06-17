package com.doday.dev.doday.service;

import com.doday.dev.doday.common.ErrorCode;
import com.doday.dev.doday.common.JwtUtil;
import com.doday.dev.doday.domain.User;
import com.doday.dev.doday.dto.LoginRequestDto;
import com.doday.dev.doday.dto.SignupRequestDto;
import com.doday.dev.doday.dto.UpdateProfileRequestDto;
import com.doday.dev.doday.mapper.UserMapper;
import com.luciad.imageio.webp.WebPWriteParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriter;
import javax.imageio.stream.FileImageOutputStream;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${upload.dir}")
    private String uploadDir;

    @Value("${server.url}")
    private String serverUrl;

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

        // null 이면 기존값 유지
        if (dto.getNickname() != null) {
            existing.setNickname(dto.getNickname());
        }

        if (dto.getPassword() != null && !dto.getPassword().isEmpty()) {
            existing.setPassword(encoder.encode(dto.getPassword()));
        }
        userMapper.update(existing);
    }

    // 프로필 이미지 업로드
    public String uploadProfileImage(Long userId, MultipartFile file) {
        try {
            // 저장 경로 설정
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            // 파일명 고유하게 설정
            String originalName = file.getOriginalFilename();
            if (originalName == null) {
                throw new IllegalArgumentException(ErrorCode.INVALID_INPUT.getMessage());
            }


            // 확장자 검사
            String ext = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
            if (ext.equals("jpg") || ext.equals("png") || ext.equals("jpeg")) {
                throw new IllegalArgumentException(ErrorCode.INVALID_FILE_TYPE.getMessage());
            }

            // 파일 크기 검사 (10MB) 제한
            if (file.getSize() > 10 * 1024 * 1024) {
                throw new IllegalArgumentException(ErrorCode.FILE_SIZE_EXCEEDED.getMessage());
            }


            // webp 파일 명
            String fileName = "user_" + userId + ".webp";

            // 기존 파일 삭제
            File existingFile = new File(uploadDir + fileName);
            if (existingFile.exists()) existingFile.delete();

            // 이미지 읽기
            BufferedImage image = ImageIO.read(file.getInputStream());

            // webp 변환 후 저장
            ImageWriter writer = ImageIO.getImageWritersByMIMEType("image/webp").next();
            WebPWriteParam writeParam = new WebPWriteParam(writer.getLocale());
            writeParam.setCompressionMode(WebPWriteParam.MODE_DEFAULT);


            // 파일 저장
            File dest = new File(uploadDir + fileName);
            writer.setOutput(new FileImageOutputStream(dest));
            writer.write(null, new IIOImage(image, null, null), writeParam);
            writer.dispose();

            // 풀 URL로 DB에 저장
            String imagePath = serverUrl + "/uploads/profile/" + fileName;
            User user = userMapper.findById(userId);
            user.setProfileImage(imagePath);
            userMapper.update(user);


            return imagePath;
        } catch (IOException e) {
            throw new RuntimeException("이미지 업로드 실패: " + e.getMessage());
        }
    }

    public User getMe(Long userId) {
        User user  = userMapper.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException(ErrorCode.USER_NOT_FOUND.getMessage());
        }
        user.setPassword(null);
        return user;
    }

    public void updateGender(Long userId, String gender) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException(ErrorCode.USER_NOT_FOUND.getMessage());
        }
        user.setGender(gender);
        userMapper.update(user);
    }
}
