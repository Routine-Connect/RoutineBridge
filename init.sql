CREATE DATABASE IF NOT EXISTS doday;
USE doday;

CREATE TABLE IF NOT EXISTS Users (
                                     id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL DEFAULT 'n',
    profile_image VARCHAR(255) NULL,
    login_fail_count INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    oauth_provider VARCHAR(20) NULL,
    oauth_id VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE IF NOT EXISTS Routines (
                                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                        user_id BIGINT NOT NULL,
                                        title VARCHAR(100) NOT NULL,
    days_of_week VARCHAR(20) NOT NULL,
    alarm_time TIME,
    is_active BOOLEAN DEFAULT TRUE,
    icon_id INT DEFAULT 1,
    sort_order INT DEFAULT 0,
    is_alarm_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS RoutineLogs (
                                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                           routine_id BIGINT NOT NULL,
                                           check_date DATE NOT NULL,
                                           is_completed BOOLEAN DEFAULT FALSE,
                                           FOREIGN KEY (routine_id) REFERENCES Routines(id)
    );

CREATE TABLE IF NOT EXISTS NotificationSettings (
                                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                                    user_id BIGINT NOT NULL UNIQUE,
                                                    is_push_enabled BOOLEAN DEFAULT TRUE,
                                                    is_routine_noti_enabled BOOLEAN DEFAULT TRUE,
                                                    is_marketing_enabled BOOLEAN DEFAULT FALSE,
                                                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS UserOAuth (
                                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                         user_id BIGINT NOT NULL,
                                         provider VARCHAR(20) NOT NULL,
    oauth_id VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS ShareTokens (
                                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                           user_id BIGINT NOT NULL UNIQUE,
                                           token VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );