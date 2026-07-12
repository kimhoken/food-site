<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <link rel="stylesheet" href="/css/mypage.css" />
    <title>회원 프로필</title>
</head>

<body>
    <div class="mypage-wrap profile-page-wrap">
        <aside class="mypage-left profile-sidebar">
            <div class="logo-box">
                <a href="/main_list.do">
                    <img src="/images/Logo.png" width="200px" height="50px" />
                </a>
            </div>

            <div class="profile-mini">
                <div class="profile-img">
                    <c:choose>
                        <c:when test="${notfound or empty profileUser.profile_img or profileUser.profile_img eq 'no_file.png'}">
                            <img src="/images/no_file.png" width="85px" height="85px" />
                        </c:when>
                        <c:otherwise>
                            <img src="/upload/profile/${profileUser.profile_img}" width="85px" height="85px" />
                        </c:otherwise>
                    </c:choose>
                </div>
                <strong>
                    <c:choose>
                        <c:when test="${notfound}">알 수 없는 회원</c:when>
                        <c:otherwise>${profileUser.nickname}</c:otherwise>
                    </c:choose>
                </strong>
                <p>
                    <c:choose>
                        <c:when test="${notfound}">프로필 정보를 찾을 수 없습니다.</c:when>
                        <c:otherwise>공개 프로필</c:otherwise>
                    </c:choose>
                </p>
            </div>

            <c:if test="${not notfound}">
                <div class="menu-section profile-menu-section">
                    <div class="sub-title">회원 활동</div>
                    <a href="/user/${profileUser.member_id}?menu=home" class="menu-item ${menu eq 'home' ? 'active' : ''}">
                        프로필 홈
                    </a>
                    <a href="/user/${profileUser.member_id}?menu=recipe" class="menu-item profile-count-link ${menu eq 'recipe' ? 'active' : ''}">
                        작성 레시피 <span>${recipeCount}</span>
                    </a>
                    <a href="/user/${profileUser.member_id}?menu=comment" class="menu-item profile-count-link ${menu eq 'comment' ? 'active' : ''}">
                        작성 댓글 <span>${commentCount}</span>
                    </a>
                </div>
            </c:if>
        </aside>

        <main class="mypage-right">
            <div class="page-header profile-page-header">
                <h2>회원 프로필</h2>
                <p>공개된 레시피와 댓글 활동을 확인할 수 있습니다.</p>
            </div>

            <c:if test="${not notfound}">
                <section class="main-box profile-hero">
                    <div class="main-left">
                        <div class="main-profile-img">
                            <c:choose>
                                <c:when test="${empty profileUser.profile_img or profileUser.profile_img eq 'no_file.png'}">
                                    <img src="/images/no_file.png" width="85px" height="85px" />
                                </c:when>
                                <c:otherwise>
                                    <img src="/upload/profile/${profileUser.profile_img}" width="85px" height="85px" />
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="main-profile-text">
                            <h3>${profileUser.nickname}</h3>
                            <p>
                                <c:choose>
                                    <c:when test="${empty profileUser.member_intro}">
                                        아직 작성된 소개가 없습니다.
                                    </c:when>
                                    <c:otherwise>
                                        ${profileUser.member_intro}
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>

                    <div class="profile-stat-list">
                        <a href="/user/${profileUser.member_id}?menu=recipe" class="profile-stat-card">
                            <strong>${recipeCount}</strong>
                            <span>레시피</span>
                        </a>
                        <a href="/user/${profileUser.member_id}?menu=comment" class="profile-stat-card">
                            <strong>${commentCount}</strong>
                            <span>댓글</span>
                        </a>
                        
                    </div>
                </section>
            </c:if>

            <section class="profile-content-box">
                <jsp:include page="${contentPage}" />
            </section>
        </main>
    </div>
</body>
</html>
