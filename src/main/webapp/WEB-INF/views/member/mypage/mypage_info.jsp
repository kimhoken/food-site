<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <head>
        <link rel="stylesheet" href="css/mypage_account.css"/>
    </head>
        <section class="info-page">
            <div class="info-card">
                <h3 class="info-title">회원 정보</h3>

                <div class="info-list">
                    
                    <div class="info-row">
                        <span class="info-label">이름</span>
                        <div class="info-value">${profileuser.name}</div>
                    </div>

                    <div class="info-row"> 
                        <span class="info-label">닉네임</span>
                        <div class="info-value">${profileuser.nickname}</div>
                    </div>

                    <div class="info-row">
                        <span class="info-label">등급</span>
                        <div class="info-value">
                            <c:if test="${profileuser.role eq 'USER'}">
                                일반 회원
                            </c:if>
                        </div>
                    </div>


                    <div class="info-row">
                        <span class="info-label">소개글</span>
                        <div class="info-value">${profileuser.member_intro}</div>
                    </div>

                    <div class="info-row">
                        <span class="info-label">이메일</span>
                        <div class="info-value">${profileuser.email}</div>
                    </div>

                    <div class="info-row">
                        <span class="info-label">가입일</span>
                        <div class="info-value">${profileuser.created_date}</div>
                    </div>

                    <div class="info-btn-box">
                        <a href="/mypage.do?menu=update">회원 정보 수정</a>
                    </div>
                </div>
            </div>
        </section>