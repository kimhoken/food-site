<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <html>

        <head>
            <link rel="stylesheet" href="/css/mypage.css" />

            <script src="/js/mypage.js"></script>
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

                                <c:when test="${profileUser.profile_img eq 'no_file.png'}">
                                    <img src="/images/no_file.png" width="85px" height="85px" />
                                </c:when>

                                <c:when test="${profileUser.profile_img ne 'no_file.png'}">
                                    <img src="/upload/profile/${profileuser.profile_img}" width="85px" height="85px" />
                                </c:when>

                            </c:choose>

                        </div>
                        <strong>${profileuser.nickname}</strong>
                        <p>맛있는 하루 되세요!</p>
                    </div>


                    <div class="menu-section">
                        <div class="sub-title">회원 활동</div>
                        <div><a href="/user/${profileUser.member_id}?menu=recipe">

                                작성한 레시피 <span>${recipeCount}</span></a></div>
                        <div><a href="/user/${profileUser.member_id}?menu=comment">

                                작성한 댓글 <span>${commentCount}</span></a></div>

                    </div>

                </aside>

                <!-- 마이페이지 오른쪽 부분 -->
                <main class="mypage-right">

                    <div class="page-header">
                        <a href="/user/${profileUser.member_id}?menu=home">
                            <h2>프로필 정보</h2>
                        </a>
                        <p>다른 회원의 활동 내역을 한 눈에 확인하세요!</p>
                    </div>
                    
                    <c:if test="${not notfound}">

                        <section class="main-box">
    
                            <div class="main-left">
                                <div class="main-profile-img">
                                    <c:choose>
    
                                        <c:when test="${profileUser.profile_img eq 'no_file.png'}">
                                            <img src="/images/no_file.png" width="85px" height="85px" />
                                        </c:when>
    
                                        <c:when test="${profileUser.profile_img ne 'no_file.png'}">
                                            <img src="/upload/profile/${profileUser.profile_img}" width="85px" height="85px" />
                                        </c:when>
    
                                    </c:choose>
                                </div>
                                <div class="main-profile-text">
    
                                    <h3>${profileUser.nickname}</h3>
                                    <div>${profileUser.member_intro}</div>
    
                                </div>
                            </div>
    
                        </section>    
    
                        
                    </c:if>
                    <jsp:include page="${contentPage}" />
                </main>

            </div>


        </body>

        </html>