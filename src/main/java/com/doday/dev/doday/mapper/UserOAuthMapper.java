package com.doday.dev.doday.mapper;

import com.doday.dev.doday.domain.UserOAuth;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserOAuthMapper {
    UserOAuth findByProviderAndOauthId(@Param("provider") String provider, @Param("oauthId") String oauthId);
    void insert(UserOAuth userOAuth);
}
