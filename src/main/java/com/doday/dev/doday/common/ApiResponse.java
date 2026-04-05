package com.doday.dev.doday.common;

import lombok.Data;

@Data
public class ApiResponse<T> {
    private boolean success;
    private T data;
    private ErrorResponse error;

    // 성공
    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setSuccess(true);
        response.data = data;
        response.error = null;
        return response;
    }


    // 실패
    public static <T> ApiResponse<T> fail(String code, String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.success = false;
        response.data = null;
        response.error = new ErrorResponse(code, message);
        return response;
    }
}
