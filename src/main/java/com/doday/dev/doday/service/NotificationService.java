package com.doday.dev.doday.service;

import com.doday.dev.doday.domain.NotificationSettings;
import com.doday.dev.doday.dto.NotificationSettingsDto;
import com.doday.dev.doday.mapper.NotificationSettingsMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {

    @Autowired
    private NotificationSettingsMapper  notificationSettingsMapper;



    public NotificationSettings getSettings(Long userId) {
        NotificationSettings settings = notificationSettingsMapper.findByUserId(userId);
        // 설정 없으면 기본값
        if (settings == null) {
            settings = new NotificationSettings();
            settings.setUserId(userId);
            settings.setIsPushEnabled(true);
            settings.setIsRoutineNotiEnabled(true);
            settings.setIsMarketingEnabled(false);
            notificationSettingsMapper.insert(settings);

            settings = notificationSettingsMapper.findByUserId(userId);
        }
        return settings;
    }

    public NotificationSettings updateSettings(Long userId, NotificationSettingsDto dto) {
        NotificationSettings settings = notificationSettingsMapper.findByUserId(userId);
        if (settings == null) {
            settings = new NotificationSettings();
            settings.setUserId(userId);
            settings.setIsPushEnabled(true);
            settings.setIsRoutineNotiEnabled(true);
            settings.setIsMarketingEnabled(false);
            notificationSettingsMapper.insert(settings);
        }

        if (dto.getIsPushEnabled() != null) settings.setIsPushEnabled(dto.getIsPushEnabled());
        if (dto.getIsRoutineNotiEnabled() != null) settings.setIsRoutineNotiEnabled(dto.getIsRoutineNotiEnabled());
        if (dto.getIsMarketingEnabled() != null) settings.setIsMarketingEnabled(dto.getIsMarketingEnabled());

        notificationSettingsMapper.update(settings);
        return settings;
    }
}
