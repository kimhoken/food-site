<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <jsp:include page="/WEB-INF/views/common/is_login.jsp" />
    <html>


    <head>
        <link rel="stylesheet" href="/css/mypage.css" />
        <title>오늘 뭐 먹지? - 마이페이지</title>
        <script src="/js/mypage.js"></script>
        <script src="/js/logout.js"></script>
    </head>

    <body>
        <div class="mypage-wrap">
            <!-- 마이페이지 왼쪽 메뉴 부분 -->
            <aside class="mypage-left">

                <div class="logo-box">
                    <a href="/main_list.do">
                        <img src="/images/Logo.png" width="200px" height="50px" />
                    </a>
                </div>

                <div class="profile-mini">
                    <div class="profile-img">
                        <c:choose>

                            <c:when test="${profileuser.profile_img eq 'no_file.png'}">
                                <img src="/images/no_file.png" width="85px" height="85px" />
                            </c:when>

                            <c:when test="${profileuser.profile_img ne 'no_file.png'}">
                                <img src="/upload/profile/${profileuser.profile_img}" width="85px" height="85px" />
                            </c:when>

                        </c:choose>

                    </div>
                    <strong>${profileuser.nickname}</strong>
                    <p>맛있는 하루 되세요!</p>
                </div>

                <div class="menu-section">
                    <div class="sub-title">회원 정보</div>
                    <div>
                        <a href="/mypage.do?menu=account" 
                           class="menu-item ${param.menu eq 'account' ? 'active' : ''}">
                           회원정보
                        </a>
                    </div>
                    <c:if test="${ not empty profileuser.password }">
                        <div>
                            <a href="/mypage.do?menu=pwd" 
                               class="menu-item ${param.menu eq 'pwd' ? 'active' : ''}">
                               비밀번호 변경
                            </a>
                        </div>
                    </c:if>
                    <div>
                        <a href="/mypage.do?menu=del" 
                           class="menu-item ${param.menu eq 'del' ? 'active' : ''}">
                           회원 탈퇴
                        </a>
                    </div>
                </div>


                <div class="menu-section">
                    <div class="sub-title"><a href="/mypage.do?menu=home">내활동</a></div>

                    <div>
                        <a href="/mypage.do?menu=recipe" 
                            class="menu-item ${param.menu eq 'recipe' ? 'active' : ''}">
                            작성한 레시피
                        </a>
                    </div>

                    <div>
                        <a href="/mypage.do?menu=comment" 
                           class="menu-item ${param.menu eq 'comment' ? 'active' : ''}">
                           작성한 댓글
                        </a>
                    </div>

                    <div>
                        <a href="/mypage.do?menu=bookmark" 
                           class="menu-item ${param.menu eq 'bookmark' ? 'active' : ''}">
                           북마크
                        </a>
                    </div>

                </div>

                <div class="menu-section">
                    <div class="sub-title">고객지원</div>
                    <div>
                        <a href="/mypage.do?menu=inquiry" 
                           class="menu-item ${param.menu eq 'inquiry' ? 'active' : ''}">
                           문의 내역
                        </a>
                    </div>
                </div>

                <button class="logout-btn" type="button" onclick="logout()">
                    <img src="/images/logout.png" />
                    로그아웃</button>
            </aside>

            <!-- 마이페이지 오른쪽 부분 -->
            <main class="mypage-right">                

                <c:if test="${ not mainshow }">
                
                    <section class="main-box">

                        <div class="main-left">
                            <div class="main-profile-img">
                                <c:choose>

                                    <c:when test="${user.profile_img eq 'no_file.png'}">
                                        <img src="/images/no_file.png" width="85px" height="85px" />
                                    </c:when>

                                    <c:when test="${user.profile_img ne 'no_file.png'}">
                                        <img src="/upload/profile/${user.profile_img}" width="85px" height="85px" />
                                    </c:when>

                                </c:choose>
                            </div>
                            <div class="main-profile-text">

                                <h3>${user.nickname}</h3>
                                <div>${user.member_intro}</div>

                            </div>
                        </div>

                        <div class="main-tag">

                            <div class="tag-card">

                                <a href="/mypage.do?menu=recipe" class="count-link">${recipeCount}</a>
                                <span>작성한 레시피</span>

                            </div>

                            <div class="tag-card">           

                                <a href="/mypage.do?menu=comment" class="count-link">${commentCount}</a>
                                <span>작성한 댓글</span>

                            </div>

                            <div class="tag-card">    

                                <a href="/mypage.do?menu=bookmark" class="count-link">${bookmarkCount}</a>
                                <span>북마크</span>
                                
                            </div>
                        </div>
                    </section>
                </c:if>

                <section class="mypage-content-box">
                    <jsp:include page="${contentPage}" />
                </section>
                
            </main>

        </div>


    </body>

    </html>