<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>오늘 뭐 먹지? - 레시피 목록</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/recipe.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/category.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search_bar.css">
        <link rel="stylesheet" href="/css/chatbot.css" />
        <script src="/js/chatbot.js"></script>
        <script src="${pageContext.request.contextPath}/js/alarm.js"></script>
        <script>
            window.onload = ()=>{
                const sort = '${sort}';
                let select = document.getElementById("sort");
                let arr = ["latest", "name", "view"];

                for(let i=0 ; i<arr.length ; i++){
                    if(arr[i] == sort){
                        select.options[i].selected = true;
                    }
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
                // select 동기화 로직 [추가]
                const sort = '${sort}';
                let select = document.getElementById("sort");
                let arr = ["latest", "name", "view", "like"];
                for (let i = 0; i < arr.length; i++){
                    if (arr[i] == sort){
                        select.options[i].selected = true;
                    }
                }

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
        </script>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/navibar.jsp">
            <jsp:param name="currentMenu" value="recipe" />
        </jsp:include>
        <form name="frm" action="/recipe_list.do" method="get">
            <div class="recipe-container">
                <!-- 왼쪽 -->
                <aside class="filter-area">
                    <div class="filter-title">필터</div>
                    <hr><br>
                    <div class="filter-section">
                        <h4>카테고리</h4>
                        <%-- 삼항 연산자를 써서 코드를 훨씬 깔끔하게 만들기 --%>
                        <label><input type="radio" name="category" value="상황별추천" ${recipeSearchDTO.category eq '상황별추천' ? 'checked' : ''}> ⭐ 상황별 추천</label>
                        <label><input type="radio" name="category" value="한식" ${recipeSearchDTO.category eq '한식' ? 'checked' : ''}> 🍚 한식</label>
                        <label><input type="radio" name="category" value="양식" ${recipeSearchDTO.category eq '양식' ? 'checked' : ''}> 🍝 양식</label>
                        <label><input type="radio" name="category" value="중식" ${recipeSearchDTO.category eq '중식' ? 'checked' : ''}> 🍳 중식</label>
                        <label><input type="radio" name="category" value="일식" ${recipeSearchDTO.category eq '일식' ? 'checked' : ''}> 🍣 일식</label>
                        <label><input type="radio" name="category" value="아시안" ${recipeSearchDTO.category eq '아시안' ? 'checked' : ''}> 🌏 아시안</label>
                        <label><input type="radio" name="category" value="건강식/다이어트" ${recipeSearchDTO.category eq '건강식/다이어트' ? 'checked' : ''}> 🥗 건강식/다이어트</label>
                        <label><input type="radio" name="category" value="초간단요리" ${recipeSearchDTO.category eq '초간단요리' ? 'checked' : ''}> ⏱️ 초간단요리</label>
                        <label><input type="radio" name="category" value="디저트" ${recipeSearchDTO.category eq '디저트' ? 'checked' : ''}> 🍰 디저트</label>
                        <label><input type="radio" name="category" value="베이킹" ${recipeSearchDTO.category eq '베이킹' ? 'checked' : ''}> 🍞 베이킹</label>
                        <label><input type="radio" name="category" value="음료/차" ${recipeSearchDTO.category eq '음료/차' ? 'checked' : ''}> ☕ 음료/차</label>
                    </div>
                    <hr><br>
                    <div class="filter-section">
                        <h4>조리시간</h4>
                        <%-- 체크박스 상태를 위해 밖에서 미리 변수 세팅하기 --%>
                        <c:set var="chk10" value=""/>
                        <c:set var="chk20" value=""/>
                        <c:set var="chk30" value=""/>
                        <c:set var="chk60" value=""/>
                        <c:set var="chk61" value=""/>

                        <c:if test="${not empty recipeSearchDTO.cookTimes}">
                            <c:forEach var="time" items="${recipeSearchDTO.cookTimes}">
                                <c:if test="${time eq '10'}"><c:set var="chk10" value="checked"/></c:if>
                                <c:if test="${time eq '20'}"><c:set var="chk20" value="checked"/></c:if>
                                <c:if test="${time eq '30'}"><c:set var="chk30" value="checked"/></c:if>
                                <c:if test="${time eq '60'}"><c:set var="chk60" value="checked"/></c:if>
                                <c:if test="${time eq '61'}"><c:set var="chk61" value="checked"/></c:if>
                            </c:forEach>
                        </c:if>
                        
                        <label><input type="checkbox" name="cookTimes" value="10" ${chk10}> 10분 이하</label>                                                                              
                        <label><input type="checkbox" name="cookTimes" value="20" ${chk20}> 10~20분</label>
                        <label><input type="checkbox" name="cookTimes" value="30" ${chk30}> 20~30분</label>
                        <label><input type="checkbox" name="cookTimes" value="60" ${chk60}> 30~60분</label>
                        <label><input type="checkbox" name="cookTimes" value="61" ${chk61}> 60분 이상</label>
                    </div>
                    <button class="filter-btn" type="button" onclick="send()">
                        적용하기
                    </button>
                    <c:if test="${not empty sessionScope.user}">
                        <div class="recipe-write-btn">
                            <input type="button" value="레시피 등록" onclick="location.href='/regiRecipe.do'" />
                        </div>
                    </c:if>
                </aside> 
                <!-- 오른쪽 -->
                <section class="recipe-area">
                    <div class="recipe-header">                                                                            
                        <select class="sort-select" name="sort" id="sort" onchange="send()">

                            <option value="latest" ${empty param.sort || param.sort eq 'latest' ? 'selected' : ''}>
                                최신순
                            </option>

                            <option value="name" ${param.sort eq 'name' ? 'selected' : ''}>
                                가나다순
                            </option>

                            <option value="view" ${param.sort eq 'view' ? 'selected' : ''}>
                                조회수순
                            </option>

                        </select>
                    </div>
                    <div class="today-recommend-header">
                        <div class="today-recommend-inner">
                            <span class="today-recommend-inner-span">TODAY</span>
                            <h5>오늘의 추천 레시피 ✨</h5>
                        </div>
                    </div>
                    <div class="recipe-list">
                        <c:choose>
                            <c:when test="${not empty emptyMsg}">
                                <%-- 빈 결과 메시지 --%>
                                <p class="empty-msg">${emptyMsg}</p>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${recipeList}" var="recipe">
                                    <a href="/recipe_detail.do?recipe_id=${recipe.recipe_id}">
                                        <div class="recipe-card">
                                            <!--썸네일 이미지-->
                                            <img src="/upload/recipe/${recipe.thumbnail}"/>
                                            <div class="recipe-info">
                                                <div class="recipe-title">${recipe.title}(${recipe.food_name})</div>
                                                <div class="recipe-meta">
                                                    ⏱ ${recipe.cooking_time}
                                                    &nbsp;&nbsp;
                                                    등록일자: ${recipe.created_date}
                                                    <br>
                                                    👁 ${recipe.view_count}
                                                    &nbsp;&nbsp;
                                                    <%-- 06-24 평점기능 추가한 부분 --%>
                                                    <c:set var="rates" value="${(recipe.rating * 10) * 2}%"/>
                                                    <div class="rate">
                                                        <span style="width: ${rates};"></span>
                                                    </div> 
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>                                                                                                                        
                    </div>
                    <%-- 페이징 --%>
                    <c:if test="${totalPage > 0 and empty emptyMsg}">
                        <div class="paging">
                            <c:set var="curPage" value="${empty recipeSearchDTO.page ? 1 : recipeSearchDTO.page}" />
                            
                            <%-- 1. 반복되는 cookTimes 쿼리 스트링을 밖에서 미리 변수로 만들어두기 --%>
                            <c:set var="cookTimesQuery" value="" />
                            <c:if test="${not empty recipeSearchDTO.cookTimes}">
                                <c:forEach var="t" items="${recipeSearchDTO.cookTimes}">
                                    <c:set var="cookTimesQuery" value="&cookTimes=${t}" />
                                </c:forEach>
                            </c:if>

                            <c:set var="nowSort" value="" />
                            <c:if test="${not empty sort}">
                                <c:set var="nowSort" value="&sort=${sort}" />
                            </c:if>

                            <%-- 1. 반복되는 cookTimes 쿼리 스트링 누적해서 이어 붙이기 --%>
                            <c:set var="cookTimesQuery" value="" />
                            <c:if test="${not empty recipeSearchDTO.cookTimes}">
                                <c:forEach var="t" items="${recipeSearchDTO.cookTimes}">
                                    <%-- 기존 cookTimesQuery 뒤에 새로운 값을 계속 붙여줌 --%>
                                    <c:set var="cookTimesQuery" value="${cookTimesQuery}&cookTimes=${t}" />
                                </c:forEach>
                            </c:if>

                            <c:set var="nowSort" value="" />
                            <c:if test="${not empty sort}">
                                <c:set var="nowSort" value="&sort=${sort}" />
                            </c:if>

                            <%-- 2. 이전 버튼 --%>
                            <a href="${curPage > 1 ? '/recipe_list.do?page='.concat(curPage - 1).concat('&category=').concat(recipeSearchDTO.category).concat(cookTimesQuery).concat(nowSort) : '#'}"
                            class="arrow ${curPage == 1 ? 'disabled' : ''}">◀</a>

                            <c:set var="startP" value="${curPage - 1 < 1 ? 1 : (curPage == totalPage and totalPage >= 3 ? totalPage - 2 : curPage - 1)}" />
                            <c:set var="endP" value="${startP + 2 > totalPage ? totalPage : startP + 2}" />
                            <c:if test="${totalPage < 1}">
                                <c:set var="startP" value="1" />
                                <c:set var="endP" value="1" />
                            </c:if>

                            <%-- 3. 페이지 번호 --%>
                            <c:forEach var="i" begin="${startP}" end="${endP}">
                                <a href="/recipe_list.do?page=${i}&category=${recipeSearchDTO.category}${cookTimesQuery}${nowSort}"
                                class="${i == curPage ? 'active' : ''}">
                                ${i}
                                </a>
                            </c:forEach>

                            <%-- 4. 다음 버튼 --%>
                            <a href="${curPage < totalPage ? '/recipe_list.do?page='.concat(curPage + 1).concat('&category=').concat(recipeSearchDTO.category).concat(cookTimesQuery).concat(nowSort): '#'}"
                            class="arrow ${curPage == totalPage || totalPage <= 1 ? 'disabled' : ''}">▶</a>

                        </div>
                    </c:if>
                </section>
            </div>
        </form>
        <!-- footer 회사 정보 jsp 파일 include -->
        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
        <!-- 챗봇 -->
        <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />
    </body>
</html>

