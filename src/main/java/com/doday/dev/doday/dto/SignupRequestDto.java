package com.doday.dev.doday.dto;

import lombok.Data;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class SignupRequestDto {

    @NotBlank(message = "이메일은 필수 입니다.")
    @Email(message = "이메일 형식이 올바르지 않습니다.")
    private String email;

    @NotBlank(message = "비밀번호는 필수 입니다.")
    @Size(min = 4, message = "비밀번호는 4자 이상이어야 합니다.")
    private String password;

    @NotBlank(message = "닉네임은 필수입니다.")
    @Size(max = 50, message = "닉네임은 50자 이하여야 합니다.")
    private String nickname;

    @NotBlank(message = "성별은 필수 입니다.")
    private String gender;
}
