<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search_bar.css">
        <script>
            window.onload = () => {
                const sort = '${sort}';
                let select = document.getElementById("sort");
                let arr = ["latest", "name", "view", "like" ];

                for(let i=0 ; i<arr.length ; i++){
                    if(arr[i] == sort){
                        select.options[i].selected = true;
                    }
                }
            }
            const logout = ()=>{
                if(confirm("로그아웃 하시겠습니까?")){
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
                            location.reload();
                        }
                    })
                }
            }
            function send() {
                let f = document.frm;
                //카테고리 선택 여부
                let catChecked = false;
                let categoryList = document.getElementsByName("category");
                for (let i = 0; i < categoryList.length; i++) {
                    if (categoryList[i].checked) {
                        catChecked = true;
                        break;
                    }
                }
                
                if (!catChecked) {
                    alert("카테고리를 선택해주세요!");
                    return;
                }
                
                f.submit();
            }//send

            document.addEventListener("DOMContentLoaded", function() {
                const searchInput = document.getElementById("mainSearch");
                const searchDropdown = document.getElementById("searchDropdown");
                
                // 1. 검색창에 포커스가 가면 드롭다운 띄우기
                searchInput.addEventListener("focus", function() {
                    searchDropdown.style.display = "block";
                });
                
                // 2. 검색창이나 드롭다운 바깥 영역을 클릭하면 닫기
                document.addEventListener("click", function(event) {
                    // 클릭한 타겟이 검색창도 아니고 드롭다운 내부도 아니면 닫음
                    if (!searchInput.contains(event.target) && !searchDropdown.contains(event.target)) {
                        searchDropdown.style.display = "none";
                    }
                });
            });

            const send_search = (f, btn) => {
                document.getElementById("mainSearch").value = btn.value;
                f.submit();
            }

            const sendRank = (val) => {
                document.getElementById("mainSearch").value = val.trim();
                document.searchForm.submit();
            }
        </script>
    </head>
    <body>
        <header>
            <div class="header-top">
                <div class="logo">
                    <a href="${pageContext.request.contextPath}/">
                        <img src="${pageContext.request.contextPath}/images/Logo.png" alt="로고"/>
                    </a>
                </div>

                <%-- 검색창 클릭시 나올 화면 --%>
                <form name="searchForm" action="${pageContext.request.contextPath}/search_recipe.do" method="post" class="search-bar-form">
                    <div class="search-wrapper" style="position: relative;">
                        <div class="search-bar">
                            <input type="text" id="mainSearch" name="search" placeholder="재료, 요리명으로 검색해보세요!" autocomplete="off">
                            <button type="submit">⌕</button>
                        </div>
                        
                        <div id="searchDropdown" class="search-dropdown">
                            <div class="search-section" id="recent">
                                <h4>최근 검색어</h4>
                                <c:if test="${empty sessionScope.currentSearchList}">
                                    <p class="empty-text">최근 검색어가 없습니다.</p>
                                </c:if>
                                <c:if test="${!empty sessionScope.currentSearchList}">
                                    <c:forEach var="item" items="${currentSearchList}" varStatus="status">
                                        <input type="button" value="${item}" onClick="send_search(this.form, this)">
                                    </c:forEach>
                                </c:if>
                            </div>
                            <div class="search-section" id="recommend">
                                <h4>추천 검색어</h4>
                                <div class="recommand-search">
                                    <c:forEach var="val" items="${recommandSearch}">
                                        <input type="button" value="${val}" onClick="send_search(this.form, this)">
                                    </c:forEach>
                                </div>
                            </div>
                            <div class="search-section">
                                <h4>급상승 검색어</h4>
                                <div class="trending-list">
                                    <c:forEach var="vo" items="${sessionScope.searchList}" varStatus="status">
                                        <div class="trending-item">
                                            <!-- 상세보기 만들면 거기에 맞는 상세보기로 바로 이동 -->
                                            <button type="button" onClick="sendRank('${vo}')"><span class="rank-num">${status.index + 1}</span> ${vo}</button>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>

                <div class="user-menu">
                    <%-- 로그인/로그아웃으로 session에 값에 따라 변경 --%>
                    <c:if test="${empty sessionScope.user}">
                        <a href="/login.do" class="menu-item" id="login">
                            <span class="menu-icon">
                                <img src="${pageContext.request.contextPath}/images/login.png">
                            </span>
                            <div>로그인</div>
                        </a>
                    </c:if>
                    <c:if test="${!empty sessionScope.user}">
                        <a href="#" class="menu-item" id="login" onClick="logout(); return false;" >
                            <span class="menu-icon">
                                <img src="${pageContext.request.contextPath}/images/login.png">
                            </span>
                            <div>로그아웃</div>
                        </a>
                    </c:if>
                    <%-- ------------------------------------------ --%>
                    <c:if test="${empty sessionScope.user}">
                        <a href="/register_form.do" class="menu-item">
                            <span class="menu-icon">
                                <img src="${pageContext.request.contextPath}/images/login.png">
                            </span>
                            <div>회원가입</div>
                        </a>
                    </c:if>
                    <c:if test="${!empty sessionScope.user}">
                        <c:choose>
                            <c:when test="${user.role eq 'ADMIN'}">
                                <a href="${pageContext.request.contextPath}/admin" class="menu-item">
                                    <span class="menu-icon">
                                        <img src="${pageContext.request.contextPath}/images/mypage.png">
                                    </span>
                                    <div>마이페이지</div>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/mypage.do" class="menu-item">
                                    <span class="menu-icon">
                                        <img src="${pageContext.request.contextPath}/images/mypage.png">
                                    </span>
                                    <div>마이페이지</div>
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </div>
            </div>

            <ul class="nav-bar">
                <li class="${param.currentMenu eq 'home' ? 'active' : ''}"><a href="/">홈</a></li>
                <li class="${param.currentMenu eq 'recipe' ? 'active' : ''}"><a href="/recipe_list.do"> 레시피</a></li>
                <li class="${param.currentMenu eq 'community' ? 'active' : ''}"><a href="/list.do">커뮤니티</a></li>
                <li class="${param.currentMenu eq 'fridge' ? 'active' : ''}"><a href="/fridge_list.do?member_id=${user.member_id}">냉장고 추천</a></li>
                <li class="${param.currentMenu eq 'guide' ? 'active' : ''}"><a href="/guide_list.do">키친가이드</a></li>
            </ul>
        </header>
    </body>
</html>