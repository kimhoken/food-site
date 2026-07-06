<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <jsp:include page="/WEB-INF/views/common/is_login.jsp" />
        <html>

        <head>
            <link rel="stylesheet" href="${pageContent.request.contentPath}/css/admin.css" />

            <script src="/js/util.js"></script>

            <script>
                let recipedetailrecipe;
                let recipeStatus;

                // 레시피 상세 보기 모달 열기 닫기 함수
                function openDetail() {
                    document.querySelector(".ra-detail").classList.add("active");
                }
                function closeDetail() {
                    document.querySelector(".ra-detail").classList.remove("active");
                }

                // 상세보기 함수
                function recipe_view(recipe_id) {

                    fetch("/admin/recipe", {
                        method: "post",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: "recipe_id=" + recipe_id
                    }).then(res => res.json())
                        .then(data => {
                            recipedetailrecipe = data.recipe.recipe_id;
                            recipeStatus = data.recipe.status;
                            fileRecipe(data.recipe);
                            renderCookOrders(data.list);
                            openDetail();
                        })
                }

                // 레시피 상세보기 데이터 값 넣는 함수
                function fileRecipe(recipe) {
                    setText("title", recipe.title);
                    setText("nickname", recipe.nickname);
                    setText("category", recipe.category_name);
                    setText("created", recipe.created_date);
                    setText("modify", recipe.updated_date);
                    setText("count", recipe.view_count);
                    setText("like", recipe.like_count);
                    setText("status", recipe.status);

                    setImg("model_img", "/upload/recipe/" + recipe.thumbnail);

                    document.querySelector(".btn-private").value=
                    recipe.status === "public"
                    ? "비공개 전환" 
                    : "공개 전환";

                    document.querySelector(".btn-delete").value=
                    recipe.status === "delete"
                    ? "복원 하기" 
                    : "삭제 하기";

                    document.querySelector(".btn-recommend").value=
                    recipe.recommend
                    ? "추천 해제" 
                    : "추천 등록";

                }

                // 상세보기 조리 순서 출력 함수
                function renderCookOrders(list) {
                    console.log(list);
                    const box = document.getElementById("cookOrderBox");
                    box.innerHTML = "";

                    list.forEach(order => {
                        box.insertAdjacentHTML("beforeend", `
            <div class="ra-step">
                <img class="ra-step-img" src="/upload/recipe/\${order.cook_image}">
                <div class="ra-step-body">
                    <div class="ra-step-title">\${order.order}단계</div>
                    <small class="ra-step-desc">\${order.description}</small>
                </div>
            </div>
        `);
                    });
                }
                
                // 레시피 공개/ 비공개 함수
                function recipeprivate() {
                    if (confirm("정말로 비공개 처리 하시겠습니까?")) {
                        fetch("/admin/private", {
                            method: 'post',
                            headers: { "Content-Type": "application/x-www-form-urlencoded" },
                            body: "recipe_id=" + recipedetailrecipe
                        }).then(res => res.json())
                            .then(data => {
                                if (data.result == 1) {
                                    alert(data.title + " 수정돠었습니다.");
                                    location.href = 'redirect:/admin?menu=recipe';
                                }
                            })
                    }
                }

                // 레시피 삭제 및 복원 함수
                function recipedel() {
                    if (!confirm("정말로 삭제 하시겠습니까?")) {

                        return;
                    }
                    fetch("/admin/recipedel", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: "recipe_id=" + recipedetailrecipe
                    }).then(res => res.json())
                        .then(data => {

                            if (data.result == 1 && data.status == "delete") {
                                alert(data.title + "가 삭제되었습니다.");
                            } else if (data.result == 1 && data.status == "public") {
                                alert(data.title + "가 복원되었습니다.");
                            } else {
                                alert("이스터에그 발견!!");
                            }
                        })
                }
                // 검색창에서 엔터시 검색되는 함수
                function eneterSearch(e) {
                    if (e.key === "Enter") {
                        searchRecipe();
                    }
                }

                // 카테고리 및 공개/비공개 레시피 조회하는 함수
                function searchRecipe() {
                    document.querySelector('form[action="/admin/recipe"]').submit();
        
                }

                // 검색 결과 리셋 함수
                function resetSearch() {

                    document.getElementById("keyword").value = "";
                    document.getElementById("category").value = "";
                    document.getElementById("status").value = "";

                    searchRecipe();
                }

                function reciperecommend() {

                    fetch("/admin/recipe/recommend", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: "recipe_id=" + recipedetailrecipe
                    }).then(res => res.json())
                        .then(data => {
                            if (data.result > 0 && data.recommend) {
                                alert(data.title + "가 추천 레시피에 등록되었습니다");
                            } else if (data.result > 0 && !data.recommend) {
                                alert(data.title + "가 추천 레시피에 해제 되었습니다.");
                            }
                        })

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
                                            <a href="#">로그아웃</a>
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
                                    <a class="admin-menu ${menu eq 'status' ? 'active'  :''}" href="/admin/status">
                                        통계 관리</a>
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
