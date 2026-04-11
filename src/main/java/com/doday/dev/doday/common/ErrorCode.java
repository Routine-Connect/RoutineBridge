package com.doday.dev.doday.common;


public enum ErrorCode {

    // 유저
    USER_NOT_FOUND("U001", "존재하지 않는 유저입니다"),
    EMAIL_DUPLICATED("U002", "이미 사용중인 이메일입니다"),
    INVALID_PASSWORD("U003", "비밀번호가 올바르지 않습니다"),
    INVALID_FILE_TYPE("F001", "jpg, jpeg, png 파일만 업로드 가능합니다."),
    FILE_SIZE_EXCEEDED("F002", "파일 크기는 10MB 이하여야 합니다."),

    // 루틴
    ROUTINE_NOT_FOUND("R001", "존재하지 않는 루틴입니다"),
    ROUTINE_UNAUTHORIZED("R002", "본인의 루틴만 수정할 수 있습니다"),
    ROUTINE_FORBBIDEN("R003", "본인의 루틴만 접근할 수 있습니다."),
    ROUTINE_INACTIVE("R004", "비활성화된 루틴입니다."),

    // 인증
    TOKEN_EXPIRED("A001", "토큰이 만료되었습니다"),
    TOKEN_INVALID("A002", "유효하지 않은 토큰입니다"),
    UNAUTHORIZED("A003", "로그인이 필요합니다"),

    // 공통
    INVALID_INPUT("C001", "입력값이 올바르지 않습니다"),
    INTERNAL_SERVER_ERROR("C002", "서버 오류가 발생했습니다");

    ErrorCode(String code, String message) {
        this.code = code;
        this.message = message;
    }

    private final String code;
    private final String message;


    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
