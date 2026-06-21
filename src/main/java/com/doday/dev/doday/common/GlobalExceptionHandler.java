package com.doday.dev.doday.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.servlet.http.HttpServletResponse;

@RestControllerAdvice
public class GlobalExceptionHandler {


    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    // 입력값 검증 실패
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<Void> handleValidation(MethodArgumentNotValidException e) {
        FieldError fieldError = e.getBindingResult().getFieldErrors().get(0);
        return ApiResponse.fail(ErrorCode.INVALID_INPUT.getCode(), fieldError.getDefaultMessage());
    }
    
    
    // 비즈니스 로직 에러
    @ExceptionHandler(IllegalArgumentException.class)
    public ApiResponse<Void> handleIllegalArgument(IllegalArgumentException e,
                                                   HttpServletResponse response) {

        if (e.getMessage().equals(ErrorCode.ROUTINE_FORBBIDEN.getMessage())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);   // 403
        }
        return ApiResponse.fail("E001", e.getMessage());
    }


    // 서버 에러
    @ExceptionHandler(Exception.class)
    public ApiResponse<Void> handleException(Exception e) {
        logger.error("서버 오류 발생", e);
        return ApiResponse.fail(
                ErrorCode.INTERNAL_SERVER_ERROR.getCode(),
                ErrorCode.INTERNAL_SERVER_ERROR.getMessage()
        );
    }
}
