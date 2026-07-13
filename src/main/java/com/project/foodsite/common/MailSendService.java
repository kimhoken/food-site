package com.project.foodsite.common;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;


import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import jakarta.mail.internet.MimeMessage;

@Component
@Service
public class MailSendService {

    private final JavaMailSender javaMailSender;
    private int authNumber;    
    private String token;
    private final String siteurl = "http://3.36.121.202/resetpwd.do?token=";
    
    public MailSendService(JavaMailSender javaMailSender) {
        this.javaMailSender = javaMailSender;
        
    }

    // 인증번호 생성
    public void makeRandomNumber() {
        Random rand = new Random();
        // 111111 ~ 999999
        authNumber = rand.nextInt(999999 - 111111 + 1) + 111111;

    }
    
    //토큰 생성 
    public void createToken() {
        SecureRandom secureRandom = new SecureRandom();

        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);

        token = Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(bytes);
    }

    //메일 함수
    public String sendEmail(String email,String val){
        String setForm = "kimhk441@naver.com";
        String toMail = email;
        Map<String,String> emailMap = new HashMap<>();

        if(val.equals("authnumber")){

            emailMap = joinEmail();

        }else if(val.equals("resetpwd")){
            emailMap = resetEmail();
        }

        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(setForm, "오늘은 뭐 먹지?");
            helper.setTo(toMail);
            helper.setSubject(emailMap.get("title"));
            helper.setText( emailMap.get("content"),true );

            javaMailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if(val.equals("authnumber")){
            return emailMap.get("authNumber");
        }else{
            return emailMap.get("token");
        }

    }
    
    // 관리자가 비회원 문의에 답변 완료했을 때 보내는 메일
    public void sendInquiryAnswerEmail( String email, String inquiryCode, String titleText, String type, String createdDate) {

        // 발신자 이메일 주소
        String setForm = "kimhk441@naver.com";

        // 비회원이 문의 답변을 확인할 수 있는 주소
        String inquiryUrl = "http://3.36.121.202/guest/inquiry/check?code=" + inquiryCode;

        String title = "오늘은 뭐 먹지? 문의 답변이 등록되었습니다.";

        String content = """
        <div style="width:100%%; background:#F7F4EE; padding:50px 0; font-family:Arial, sans-serif;">

            <div style="
                width:720px;
                margin:0 auto;
                background:#ffffff;
                border:1px solid #E5D8BE;
                border-radius:10px;
                overflow:hidden;
            ">

                <div style="
                    padding:24px 50px;
                    background:#FBF7EF;
                    border-bottom:1px solid #E5D8BE;
                    text-align:left;
                ">
                    <span style="
                        font-size:24px;
                        font-weight:bold;
                        color:#556B3E;
                    ">
                        오늘은 뭐 먹지?
                    </span>
                </div>

                <div style="padding:50px 70px;">

                    <h2 style="
                        text-align:center;
                        font-size:30px;
                        color:#3A3028;
                        margin-bottom:30px;
                    ">
                        문의 답변이 등록되었습니다
                    </h2>

                    <table style="
                        width:100%%;
                        border-collapse:collapse;
                        margin-bottom:35px;
                    ">
                        <tr>
                            <td style="
                                width:140px;
                                padding:14px;
                                background:#F8F4EC;
                                border:1px solid #E5D8BE;
                                font-weight:bold;
                                color:#556B3E;
                            ">
                                문의 유형
                            </td>

                            <td style="
                                padding:14px;
                                border:1px solid #E5D8BE;
                            ">
                                %s
                            </td>
                        </tr>

                        <tr>
                            <td style="
                                padding:14px;
                                background:#F8F4EC;
                                border:1px solid #E5D8BE;
                                font-weight:bold;
                                color:#556B3E;
                            ">
                                문의 제목
                            </td>

                            <td style="
                                padding:14px;
                                border:1px solid #E5D8BE;
                            ">
                                %s
                            </td>
                        </tr>

                        <tr>
                            <td style="
                                padding:14px;
                                background:#F8F4EC;
                                border:1px solid #E5D8BE;
                                font-weight:bold;
                                color:#556B3E;
                            ">
                                접수일
                            </td>

                            <td style="
                                padding:14px;
                                border:1px solid #E5D8BE;
                            ">
                                %s
                            </td>
                        </tr>

                        <tr>
                            <td style="
                                padding:14px;
                                background:#F8F4EC;
                                border:1px solid #E5D8BE;
                                font-weight:bold;
                                color:#556B3E;
                            ">
                                문의코드
                            </td>

                            <td style="
                                padding:14px;
                                border:1px solid #E5D8BE;
                                font-weight:bold;
                                color:#556B3E;
                                word-break:break-all;
                            ">
                                %s
                            </td>
                        </tr>
                    </table>

                    <p style="
                        text-align:center;
                        font-size:17px;
                        color:#555555;
                        line-height:1.8;
                        margin-bottom:35px;
                    ">
                        문의 작성 시 입력한 비밀번호를 입력하면<br>
                        관리자 답변을 확인할 수 있습니다.
                    </p>

                    <div style="text-align:center;">
                        <a href="%s"
                        style="
                            display:inline-block;
                            padding:16px 40px;
                            background:#556B3E;
                            color:white;
                            text-decoration:none;
                            border-radius:8px;
                            font-size:18px;
                            font-weight:bold;
                        ">
                            답변 확인하기
                        </a>
                    </div>

                    <p style="
                        margin-top:40px;
                        font-size:14px;
                        color:#888888;
                        text-align:center;
                        line-height:1.8;
                    ">
                        본인이 문의하지 않았다면 이 메일을 무시하세요.
                    </p>

                </div>

                <div style="
                    padding:22px 50px;
                    background:#FBF7EF;
                    border-top:1px solid #E5D8BE;
                    text-align:center;
                    color:#777777;
                    font-size:14px;
                ">
                    감사합니다.
                    <strong style="color:#556B3E;">
                        오늘은 뭐 먹지?
                    </strong>
                </div>

            </div>

        </div>
        """.formatted(
                type,
                titleText,
                createdDate,
                inquiryCode,
                inquiryUrl
        );

        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(setForm, "오늘은 뭐 먹지?");
            helper.setTo(email);
            helper.setSubject(title);
            helper.setText(content, true);

            javaMailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    // 인증 번호 메일 발송 
    public Map<String,String> joinEmail(){
        
        makeRandomNumber();
        String title = "오늘은 뭐 먹지? 인증 이메일 입니다.";

        String content = """
            <div>
                <h2>이메일 인증번호</h2>
                <p>아래 인증번호를 입력해 주세요.</p>
                <h1>%s</h1>
            </div>
            """.formatted(authNumber);

        Map<String,String> email = new HashMap<>();
        email.put("title", title);
        email.put("content", content);
        email.put("authNumber", String.valueOf(authNumber));
        
        return email;
    }

    //비밀번호 재설정 페이지 전송 함수
    public Map<String,String> resetEmail(){
        String title = "오늘은 뭐 먹지? 비밀번호 재설정 이메일 입니다.";
        createToken();
        String resetUrl = siteurl + token;        
        String content = """
        <div style="width:100%%; background:#F7F4EE; padding:50px 0; font-family:Arial, sans-serif;">

            <div style="
                width:720px;
                margin:0 auto;
                background:#ffffff;
                border:1px solid #E5D8BE;
                border-radius:10px;
                overflow:hidden;
            ">

                <div style="
                    padding:24px 50px;
                    background:#FBF7EF;
                    border-bottom:1px solid #E5D8BE;
                    text-align:left;
                ">
                    <img src="cid:logo" width="46" style="vertical-align:middle; margin-right:12px;">
                    <span style="
                        font-size:24px;
                        font-weight:bold;
                        color:#556B3E;
                        vertical-align:middle;
                    ">
                        오늘은 뭐 먹지?
                    </span>
                </div>

                <div style="padding:50px 70px; text-align:center;">

                    <h2 style="
                        font-size:30px;
                        color:#3A3028;
                        margin-bottom:20px;
                    ">
                        비밀번호 재설정
                    </h2>

                    <p style="
                        font-size:17px;
                        color:#555555;
                        line-height:1.8;
                        margin-bottom:40px;
                    ">
                        비밀번호 재설정 요청이 접수되었습니다.<br>
                        아래 버튼을 눌러 새로운 비밀번호를 설정해 주세요.
                    </p>

                    <a href="%s"
                    style="
                        display:inline-block;
                        padding:16px 40px;
                        background:#556B3E;
                        color:white;
                        text-decoration:none;
                        border-radius:8px;
                        font-size:18px;
                        font-weight:bold;
                    ">
                        비밀번호 재설정
                    </a>

                    <p style="
                        margin-top:40px;
                        font-size:14px;
                        color:#888888;
                        line-height:1.8;
                    ">
                        본 링크는 30분 후 만료됩니다.<br>
                        본인이 요청하지 않았다면 이 메일을 무시하세요.
                    </p>

                </div>

                <div style="
                    padding:22px 50px;
                    background:#FBF7EF;
                    border-top:1px solid #E5D8BE;
                    text-align:center;
                    color:#777777;
                    font-size:14px;
                ">
                    감사합니다. <strong style="color:#556B3E;">오늘은 뭐 먹지?</strong>
                </div>

            </div>

        </div>
        """.formatted(resetUrl);

        Map<String,String> email = new HashMap<>();
        email.put("title", title);
        email.put("content", content.toString());
        email.put("token", token);

        return email;
    }
}
