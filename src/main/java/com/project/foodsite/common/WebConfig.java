package com.project.foodsite.common;

import java.nio.file.Paths;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${file.upload.path}")
    private String uploadPath;
    
    // 파일 저장 경로 세팅 함수
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry)    {

        String path = Paths.get(uploadPath).toUri().toString(); 
        registry.addResourceHandler("/upload/**")                
                .addResourceLocations(path); 
    
    }
}
