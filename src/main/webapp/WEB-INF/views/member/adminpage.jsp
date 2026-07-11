<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <jsp:include page="/WEB-INF/views/common/is_login.jsp" />
        <c:if test="${profileuser.role ne 'ADMIN'}">
            <script>
                alert("관리자만 이용할수 있습니다.");
                location.href="main_list.do";
            </script>
        </c:if>
        <html>

        <head>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_recipe.css" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_mypage.css" />

            <script src="/js/util.js"></script>

            <script>

                const logout = () => {
                    if (confirm("로그아웃 하시겠습니까?")) {
                        fetch("/logout.do", {
                            method: "post",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify({
                                id: "${user.member_id}"
                            })
                        })
                            .then(res => res.json())
                            .then(data => {
                                if (data.result == "success") {
                                    alert("로그아웃 되었습니다.")
                                    location.href = "/main_list.do";
                                }
                            })
                    }
                }



                
                // 관리자 정보 드롭 업/다운 시켜주는 기능
                document.addEventListener("DOMContentLoaded", () => {
                    const profileName = document.querySelector(".profile-name");
                    const profileTrigger = document.querySelector(".profile-trigger");

                    if (!profileName || !profileTrigger) return;

                    profileTrigger.addEventListener("click", (event) => {

                        event.stopPropagation();
                        const isOpen = profileName.classList.toggle("open");
                        profileTrigger.setAttribute("aria-expanded", isOpen);
                    });

                    document.addEventListener("click", (event) => {
                        if (profileName.contains(event.target)) return;

                        profileName.classList.remove("open");
                        profileTrigger.setAttribute("aria-expanded", "false");
                    });

                    document.addEventListener("keydown", (event) => {
                        if (event.key !== "Escape") return;

                        profileName.classList.remove("open");
                        profileTrigger.setAttribute("aria-expanded", "false");
                    });
                });

            </script>
        </head>

        <body>
            <div class="admin-layout">

                <div class="admin-wrap">
                    <!-- 마이페이지 왼쪽 메뉴 부분 -->
                    <aside class="admin-left">

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
                                        <img src="/upload/profile/${profileuser.profile_img}" width="85px"
                                            height="85px" />
                                    </c:when>

                                </c:choose>

                            </div>
                            <ul class="profile-menu">
                                <li class="profile-name">
                                    <button type="button" class="profile-trigger" aria-expanded="false">
                                        <strong>${profileuser.nickname}</strong>
                                        <span class="menu-arrow" aria-hidden="true">⌄</span>
                                    </button>

                                    <ul class="profile-submenu">
                                        <li>
                                            <a href="/admin/mypage">내 정보</a>
                                        </li>

                                        <li>
                                            <a href="#" onclick="logout()">로그아웃</a>
                                        </li>
                                    </ul>
                                </li>
                            </ul>
                            <p>맛있는 하루 되세요!</p>
                        </div>


                        <div class="menu-section">
                            <div class="sub-title">운영 관리</div>
                            <ul class="admin-menu-list">
                                <li>
                                    <a class="admin-menu ${menu eq 'home' ? 'active'  :''}" href="/admin">
                                        대시 보드</a>
                                </li>

                                <li>
                                    <a class="admin-menu ${menu eq 'user' ? 'active'  : ''}" href="/admin/member">
                                        회원 관리</a>
                                </li>

                                <li class="has-sub">
                                    <a class="admin-menu ${menu eq 'recipe' ? 'active' :''}" href="/admin/recipe">
                                        <span>레시피 관리</span>
                                        <span class="menu-arrow" aria-hidden="true">›</span>
                                    </a>
                                    <ul class="admin-submenu">
                                        <li>
                                            <a href="/admin/recipe">전체 레시피</a>
                                        </li>

                                        <li>
                                            <a href="/admin/recipe?recommend=true">추천 레시피</a>
                                        </li>

                                        <li>
                                            <a href="/admin/recipe?status=delete">삭제 레시피</a>
                                        </li>

                                        <li>
                                            <a href="/admin/review">레시피 후기</a>
                                        </li>
                                    </ul>
                                </li>

                                
                                <li>
                                    <a class="admin-menu ${menu eq 'status' ? 'active'  :''}" href="/admin/board">
                                        게시글 관리</a>
                                </li>
                                <li>
                                    <a class="admin-menu ${menu eq 'status' ? 'active'  :''}" href="/admin/comment">
                                        댓글 관리</a>
                                </li>
                            </ul>

                        </div>


                        <div class="menu-section">
                            <div class="sub-title">고객지원</div>

                            <a class="admin-menu ${menu eq 'inquiry' ? 'active' :''}" href="/admin/inquiry">
                                문의 관리</a>
                            <a class="admin-menu ${menu eq 'report' ? 'active' :''}" href="/report/admin/list.do">
                                신고 관리</a>
                        </div>



                    </aside>

                    <main class="admin-main">
                        <div class="admin-container">
                            <jsp:include page="${contentPage}" />
                        </div>
                    </main>

                </div>
            </div>
        </body>

        </html>
