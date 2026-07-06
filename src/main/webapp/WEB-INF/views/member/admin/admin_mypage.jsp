<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <section class="info-page">
            <div class="info-card">
                <div class="info-header">
                    <div>
                        <h3 class="info-title">관리자 정보</h3>
                        <p class="info-desc">현재 로그인한 관리자 계정 정보를 확인할 수 있습니다.</p>
                    </div>
                    <a class="info-edit-link" href="/admin/update">정보 수정</a>
                </div>

                <div class="info-list">
                    <div class="info-profile">
                        <c:choose>

                            <c:when test="${profileuser.profile_img eq 'no_file.png'}">
                                <img src="/images/no_file.png" />
                            </c:when>

                            <c:when test="${profileuser.profile_img ne 'no_file.png'}">
                                <img src="/upload/profile/${profileuser.profile_img}" />
                            </c:when>

                        </c:choose>
                        <div>
                            <strong>${profileuser.nickname}</strong>
                            <span>관리자</span>
                        </div>
                    </div>

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
                            <c:if test="${profileuser.role eq 'ADMIN'}">
                                관리자
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

                </div>
            </div>
        </section>
