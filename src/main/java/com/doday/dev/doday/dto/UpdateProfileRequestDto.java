package com.doday.dev.doday.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class UpdateProfileRequestDto {

    @NotBlank(message = "닉네임은 필수입니다.")
    @Size(max = 50, message = "닉네임은 50자 이하여야 합니다.")
    private String nickname;

    @Size(min = 4, message = "비밀번호는 4자 이상이어야 합니다.")
    private String password;
}
