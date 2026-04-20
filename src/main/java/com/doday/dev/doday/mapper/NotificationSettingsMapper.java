package com.doday.dev.doday.mapper;

import com.doday.dev.doday.domain.NotificationSettings;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface NotificationSettingsMapper {
    NotificationSettings findByUserId(Long userId);
    void insert(NotificationSettings notificationSettings);
    void update(NotificationSettings notificationSettings);
}
