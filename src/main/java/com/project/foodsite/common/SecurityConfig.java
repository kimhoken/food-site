package com.project.foodsite.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class SecurityConfig {
    
    private final OAuth2SuccessHandler auth2SuccessHandler;
    
    // 
    @Bean   
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception{

        http.csrf(csrf->csrf.disable())
        .authorizeHttpRequests(auth->auth
            .anyRequest().permitAll()
        )
        .oauth2Login(oauth->oauth
            .loginPage("/login.do")
            .successHandler(auth2SuccessHandler)
        );
        
        return http.build();
    }

}
