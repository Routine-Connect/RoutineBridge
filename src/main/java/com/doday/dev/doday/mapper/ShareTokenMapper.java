package com.doday.dev.doday.mapper;

import com.doday.dev.doday.domain.ShareToken;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ShareTokenMapper {
    ShareToken findByUserId(Long userId);
    ShareToken findByToken(String token);
    void insert(ShareToken shareToken);
    void update(ShareToken shareToken);
}
