package com.routinebridge.dev.routinebridge.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;


    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String uri = request.getRequestURI();

        // 인증 제외 경로 (회원가입, 로그인, Swagger)
        if (isExcluded(uri)) {
            filterChain.doFilter(request, response);
            return;
        }

        // Authorization 헤더에서 토큰 추출
        String header = request.getHeader("Authorization");

        if (header == null || !header.startsWith("Bearer ")) {
            sendError(response, "토큰이 없습니다.");
            return;
        }

        String token = header.substring(7); // "Bearer " 제거

        // 토큰 유효성 검사
        if (!jwtUtil.validateToken(token)) {
            sendError(response, "유효하지 않은 토큰입니다.");
            return;
        }

        // 토큰에서 userid 추출해서 request에 담기
        Long userId = jwtUtil.getUserId(token);
        request.setAttribute("userId", userId);

        filterChain.doFilter(request, response);
    }


    // 인증 제외 경로
    private boolean isExcluded(String uri) {
        return uri.equals("/api/users/signup") ||
                uri.equals("/api/users/login") ||
                uri.startsWith("/swagger-ui") ||
                uri.startsWith("/v2/api-docs") ||
                uri.startsWith("/webjars") ;
    }

    // 401 에러 응답
    private void sendError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(
                "{\"success\":false,\"data\":null,\"error\":{\"code\":\"A003\",\"message\":\"" + message + "\"}}"
        );
    }
}
