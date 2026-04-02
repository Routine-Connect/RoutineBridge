package com.routinebridge.dev.routinebridge.common;

import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import java.util.Base64;

public class KeyGenerator {
    public static void main(String[] args) {
        String key = Base64.getEncoder()
                .encodeToString(Keys.secretKeyFor(SignatureAlgorithm.HS256).getEncoded());
        System.out.println("JWT Secret Key: " + key);
    }
}
