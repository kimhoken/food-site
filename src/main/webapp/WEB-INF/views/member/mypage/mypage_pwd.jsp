<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<head>
    <link rel="stylesheet" href="css/mypage_account.css"/>
    <script src="/js/mypage_pwd.js"></script>
</head>

<section class="pwd-page">

        
        <div id="pwd_box" class="pwd-card">
            <h2 class="pwd-title">비밀번호 재설정 페이지</h2>

            <p class="pwd-desc">
            회원님의 정보를 보호하기 위해 현재 비밀번호를 먼저 확인해주세요.
            </p>
            <div class="pwd-row">
                <label class="pwd-label">현재 비밀번호</label>
                <div class="pwd-control">
                    <input type="password" class="pwd-input" placeholder="비밀번호 입력해주세요!" id="pwdUserCheck"/>
                    
                </div>
            </div>

            <div class="pwd-btn-area">
                <input type="button" class="pwd-main-btn" value="비밀번호 확인" onclick="pwdUserCheck()"/>

            </div>
        </div>
   
   
        <div id="pwd_reset_box" class="pwd-card" style="display: none;">
            <form class="pwd-form">

                        <h2 class="pwd-title">비밀번호 재설정</h2>
                        <div class="pwd-row">
                            <span class="pwd-label">비밀번호</span>
                            <div class="pwd-control">
                                <input type="password" class="pwd-input" id="pwd" name="pwd" placeholder="비밀번호 입력하세요"
                                    onChange="pwdchange()" />
                                <div class="pwd-msg" id="pwd_msg">영문 특수문자 10글자 이상</div>
                            </div>
                        </div>

                        <div class="pwd-row">
                            <span class="pwd-label">비밀번호 확인</span>
                            <div class="pwd-control">
                                <input type="password" id="pwd_check" class="pwd-input" name="pwd_check" placeholder="비밀번호 확인 입력하세요"
                                    onChange="pwdchange()" />
                                <div class="pwd-msg" id="pwd_check_msg"></div>
                            </div>
                        </div>

                        <div class="pwd-btn-area">
                            <input type="button" class="pwd-main-btn" value="비밀번호 재설정" onclick="password_reset(this.form)" />
                        </div>

                    </form>

        </div>

    
</section>