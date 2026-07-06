package com.project.foodsite.common;

import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Date;
import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.project.foodsite.dao.MemberDAO;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest; 
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    private final MemberDAO memberDAO;
    
    // 소셜 로그인 성공 시 처리할 로직 구현
    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication) throws IOException, ServletException {

        OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) authentication;

        String provider = token.getAuthorizedClientRegistrationId();

        OAuth2User oauthuser = (OAuth2User) authentication.getPrincipal();

        Map<String, Object> attributes = oauthuser.getAttributes();

        MemberVO socialUser = null;

        if (provider.equals("naver")) {
            socialUser = getNaverUser(attributes);
        } else if (provider.equals("kakao")) {
            socialUser = getKakaoUser(attributes);
        } else if (provider.equals("google")) {
            socialUser = getGoogleUser(attributes);
        }

        

        if (socialUser == null) {
            response.sendRedirect("/login.do?error");
            return;
        }   

        // DB 조회
        MemberVO member = memberDAO.getSocialUser(socialUser.getProvider(), socialUser.getProvider_id());

        
        // 회원가입 여부 판단
        if (member == null) {
            request.getSession().setAttribute("socialUser", socialUser);
                       
            response.sendRedirect("/register_form.do");
            return;
        }

        if("SUSPEND".equals(member.getStatus())){
            if(member.getSuspend_end() != null && member.getSuspend_end().after(new Date())){
                
                String day = member.getSuspend_end().toString();

                response.sendRedirect("/login.do?error=SUSPEND&day=" + day);
                return ;
            }

            memberDAO.relaseSuspend(member.getMember_id());

            member.setStatus("ACTIVE");
            member.setSuspend_start(null);
            member.setSuspend_end(null);
            
        }

        request.getSession().setAttribute("user", member);
        response.sendRedirect("/main_list.do");

    }

    // 네이버 사용자 정보 추출
    private MemberVO getNaverUser(Map<String, Object> attributes) {
        @SuppressWarnings("unchecked")
        Map<String, Object> naver = (Map<String, Object>) attributes.get("response");

        MemberVO vo = new MemberVO();

        vo.setProvider("naver");
        vo.setProvider_id((String) naver.get("id"));
        vo.setEmail((String) naver.get("email"));
        vo.setName((String) naver.get("name"));
        vo.setNickname((String) naver.get("nickname"));
        vo.setFilename(saveSocialImg((String) naver.get("profile_image"), "naver",(String) naver.get("id")));
        vo.setLogin_type("SOCIAL");
        
        return vo;
        
    }
    
    // 카카오 사용자 정보 추출
    private MemberVO getKakaoUser(Map<String,Object> attributes) {
        @SuppressWarnings("unchecked")
        Map<String,Object> kakao = (Map<String, Object>) attributes.get("kakao_account");
        @SuppressWarnings("unchecked")
        Map<String,Object> profile =(Map<String, Object>) kakao.get("profile");
        
        MemberVO vo = new MemberVO();
        
        vo.setProvider("kakao");
        vo.setProvider_id(String.valueOf(attributes.get("id")));
        vo.setEmail((String) kakao.get("email"));        
        vo.setNickname((String) profile.get("nickname"));
        vo.setFilename(saveSocialImg((String) kakao.get("profile_image"), "kakao",(String) kakao.get("id")));
        
        vo.setLogin_type("SOCIAL");
        
        return vo;
    }
    
    // 구글 사용자 정보 추출
    private MemberVO getGoogleUser(Map<String, Object> attributes) {
        
        MemberVO vo = new MemberVO();
        
        vo.setProvider("google");
        vo.setProvider_id((String) attributes.get("sub"));
        vo.setEmail((String) attributes.get("email"));
        vo.setName((String) attributes.get("name"));
        vo.setNickname((String) attributes.get("name"));
        vo.setFilename(saveSocialImg((String) attributes.get("picture"), "google",(String) attributes.get("id")));
        vo.setLogin_type("SOCIAL");

        return vo;
    }

    // 소셜 로그인에서 이미지 DB에 저장
    private String saveSocialImg(String imgurl, String provider, String provider_id){
        try {
            String filename = provider + "_" + provider_id+".png"; 

            //경로 설정
            Path target = Paths.get("C:/upload", filename);

            //파일 복사
            if(!Files.exists(target)){
                Files.copy(new URL(imgurl).openStream(), target);                
            }

            return filename;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return "no_file.png";
    }





}





