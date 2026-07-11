<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/is_login.jsp" />
<jsp:include page="/WEB-INF/views/common/navibar.jsp" />
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<!DOCTYPE html>
<html>
<head>
    <title>오늘 뭐먹지? - 레시피 작성하기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/regiRecipe.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/recipe.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/category.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search_bar.css">
    <link rel="stylesheet" href="/css/chatbot.css" />
    <script src="/js/chatbot.js"></script>
    <script src="${pageContext.request.contextPath}/js/alarm.js"></script>

    <script>
        function send(f) {
            const ingredients = document.getElementsByName("ingredientName");
            const steps = document.getElementsByName("step");
            
            if (f.title.value.trim() === "") {
                alert("제목을 입력하세요.");
                f.title.focus();
                return;
            }
            
            if (f.mainImg.value.trim() === "") {
                alert("대표 이미지를 선택하세요.");
                return;
            }
            
            if (ingredients[0].value.trim() === "") {
                alert("재료를 입력하세요.");
                ingredients[0].focus();
                return;
            }
            
            if (steps[0].value.trim() === "") {
                alert("조리순서를 입력하세요.");
                return;
            }
            
            f.submit();
        }
        
        // 썸네일 미리보기
        function previewImage(input) {
            const file = input.files[0];
            if (!file) {
                return;
            }
            
            const reader = new FileReader();
            reader.onload = function (e) {
                const preview = document.getElementById('thumbnailPreview'); //<img id="thumbnailPreview">
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            
            reader.readAsDataURL(file);
        }
        
        // 조리순서 이미지 미리보기
        function previewStep(input) {
            console.log("조리순서 이미지 미리보기 함수 실행됨");
            
            const file = input.files[0];
            if (!file) {
                return;
            }
            
            const reader = new FileReader();
            reader.onload = function (e) {
                const preview = input.parentElement.querySelector("img"); //파일 선택한 바로 아래 <img> 태그 찾아
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            
            reader.readAsDataURL(file);
        }
        
        // 재료 추가 함수
        function addIngredient() {
            const table = document.getElementById('ingredientTable');
            const newRow = table.insertRow();
            
            newRow.innerHTML = `
                <td><input type="text" name="ingredientName"></td>
                <td><input type="number" name="amount" min="0.1" step="0.1"></td>
                <td>
                    <select name="unit" onchange="changeUnit(this)">
                        <option value="개">개</option>
                        <option value="g">g</option>
                        <option value="kg">kg</option>
                        <option value="ml">ml</option>
                        <option value="큰술">큰술</option>
                        <option value="작은술">작은술</option>
                        <option value="컵">컵</option>
                        <option value="direct">직접입력</option>
                    </select>
                    
                    <input type="text" name="customUnit" placeholder="단위 입력" style="display:none;" />
                    
                    <button type="button" onclick="removeRow(this)" class="x-btn">
                        X
                    </button>
                </td>
            `;
        }
        
        // '직접입력' 선택시 그 자리에서 입력하기
        function changeUnit(select) {
            if (select.value === "direct") {
                // input 생성
                const input = document.createElement("input");
                input.type = "text";
                input.name = "unit";
                input.placeholder = "단위 입력";
                
                // 엔터나 포커스 해제 시 다시 select로 복구
                input.onblur = function () {
                    if (input.value.trim() === "") {
                        select.selectedIndex = 0;
                    } else {
                        const option = document.createElement("option");
                        option.value = input.value;
                        option.text = input.value;
                        option.selected = true;
                        
                        select.appendChild(option);
                    }
                    
                    input.replaceWith(select);
                };
                
                // select를 input으로 교체
                select.replaceWith(input);
                input.focus();
            }
        }
        
        // 재료 줄 삭제
        function removeRow(btn) {
            const table = document.getElementById("ingredientTable");
            
            if (table.rows.length <= 2) {
                alert("재료는 최소 1개 이상 필요합니다.");
                return;
            }
            
            btn.closest("tr").remove();
        }
        
        // 조리순서 번호를 1부터 다시 매기는 함수
        function updateStepNumbers() {
            // stepBody 안에 있는 모든 .step-number 요소를 가져와
            // 띄어쓰기-> 자식 선택!
            const steps = document.querySelectorAll('#stepBody .step-number');
            
            steps.forEach((step, index) => {
                // index는 0부터 시작이라 +1해서 넣어
                step.innerHTML = index + 1;
            });
        }
        
        // 조리순서 추가 함수
        function addStep() {
            const tbody = document.getElementById('stepBody');
            // 새로운 행(tr) 생성
            const newRow = document.createElement('tr');
            
            // 처음부터 번호 계산 x, updateStepNumbers: 선 생성 번호매김 후 처리
            newRow.innerHTML = `
                <td align="center">
                    <div class="step-number">1</div>
                </td>
                
                <td>
                    <input type="file" name="stepImg" onchange="previewStep(this)" />
                    <br/>
                    <img class="step-image" src="#" alt="조리순서 이미지 미리보기"/>
                </td>
                
                <td>
                    <div class="step-content">
                        <textarea name="step" rows="5" cols="50" placeholder="다음 조리 과정을 입력하세요."></textarea>
                        <button type="button" onclick="removeRow2(this)" class="x-btn2">X</button>
                    </div>
                </td>
            `;
            
            // tbody에 추가
            tbody.appendChild(newRow);
            
            // 추가 후 번호 갱신
            updateStepNumbers();
        }
        
        // 원하는 줄 삭제
        function removeRow2(btn) {
            const row = btn.closest('tr');
            const rows = document.querySelectorAll('#stepBody tr');
            
            if (rows.length <= 1) {
                alert("조리순서는 최소 1개 이상 필요합니다.");
                return;
            }
            
            // 찾은 줄 삭제
            row.remove();
            // 선택한 줄 삭제 후 번호 재정렬
            updateStepNumbers();
        }
    </script>

    <style>
        textarea {
            resize: none;
        }
    </style>
</head>
<body>
    <form action="/myrecipe.do" method="post" enctype="multipart/form-data">
        <input type="hidden" name="memberId" value="${sessionScope.user.member_id}" />
        
        <form name="frm" action="${pageContext.request.contextPath}/recipe_list.do" method="get">
            <div class="recipe-container">
                <aside class="filter-area">
                    <div class="filter-title">필터</div>
                    <hr><br>
                    
                    <div class="filter-section">
                        <h4>카테고리</h4>
                        <%-- 삼항 연산자를 써서 코드를 훨씬 깔끔하게 만들기 --%>
                        <label>
                            <input type="radio" name="category" value="상황별추천" ${recipeSearchDTO.category eq '상황별추천' ? 'checked' : '' }> ⭐ 상황별 추천
                        </label>
                        <label>
                            <input type="radio" name="category" value="한식" ${recipeSearchDTO.category eq '한식' ? 'checked' : '' }> 🍚 한식
                        </label>
                        <label>
                            <input type="radio" name="category" value="양식" ${recipeSearchDTO.category eq '양식' ? 'checked' : '' }> 🍝 양식
                        </label>
                        <label>
                            <input type="radio" name="category" value="중식" ${recipeSearchDTO.category eq '중식' ? 'checked' : '' }> 🍳 중식
                        </label>
                        <label>
                            <input type="radio" name="category" value="일식" ${recipeSearchDTO.category eq '일식' ? 'checked' : '' }> 🍣 일식
                        </label>
                        <label>
                            <input type="radio" name="category" value="아시안" ${recipeSearchDTO.category eq '아시안' ? 'checked' : '' }> 🌏 아시안
                        </label>
                        <label>
                            <input type="radio" name="category" value="건강식/다이어트" ${recipeSearchDTO.category eq '건강식/다이어트' ? 'checked' : '' }> 🥗 건강식/다이어트
                        </label>
                        <label>
                            <input type="radio" name="category" value="초간단요리" ${recipeSearchDTO.category eq '초간단요리' ? 'checked' : '' }> ⏱️ 초간단요리
                        </label>
                        <label>
                            <input type="radio" name="category" value="디저트" ${recipeSearchDTO.category eq '디저트' ? 'checked' : '' }> 🍰 디저트
                        </label>
                        <label>
                            <input type="radio" name="category" value="베이킹" ${recipeSearchDTO.category eq '베이킹' ? 'checked' : '' }> 🍞 베이킹
                        </label>
                        <label>
                            <input type="radio" name="category" value="음료/차" ${recipeSearchDTO.category eq '음료/차' ? 'checked' : '' }> ☕ 음료/차
                        </label>
                    </div>
                    <hr><br>
                    
                    <div class="filter-section">
                        <h4>조리시간</h4>
                        <%-- 체크박스 상태를 위해 밖에서 미리 변수 세팅하기 --%>
                        <c:set var="chk10" value="" />
                        <c:set var="chk20" value="" />
                        <c:set var="chk30" value="" />
                        <c:set var="chk60" value="" />
                        <c:set var="chk61" value="" />

                        <c:if test="${not empty recipeSearchDTO.cookTimes}">
                            <c:forEach var="time" items="${recipeSearchDTO.cookTimes}">
                                <c:if test="${time eq '10'}">
                                    <c:set var="chk10" value="checked" />
                                </c:if>
                                <c:if test="${time eq '20'}">
                                    <c:set var="chk20" value="checked" />
                                </c:if>
                                <c:if test="${time eq '30'}">
                                    <c:set var="chk30" value="checked" />
                                </c:if>
                                <c:if test="${time eq '60'}">
                                    <c:set var="chk60" value="checked" />
                                </c:if>
                                <c:if test="${time eq '61'}">
                                    <c:set var="chk61" value="checked" />
                                </c:if>
                            </c:forEach>
                        </c:if>

                        <%-- 세팅된 변수를 EL로 넣어주기만 하면 끝 --%>
                        <label>
                            <input type="checkbox" name="cookTimes" value="10" ${chk10}> 10분 이하
                        </label>
                        <label>
                            <input type="checkbox" name="cookTimes" value="20" ${chk20}> 10~20분
                        </label>
                        <label>
                            <input type="checkbox" name="cookTimes" value="30" ${chk30}> 20~30분
                        </label>
                        <label>
                            <input type="checkbox" name="cookTimes" value="60" ${chk60}> 30~60분
                        </label>
                        <label>
                            <input type="checkbox" name="cookTimes" value="61" ${chk61}> 60분 이상
                        </label>
                    </div>
                    
                    <button class="filter-btn" type="button" onclick="send()">적용하기</button>
                </aside>

                <section class="recipe-area">
                    <div class="recipe-header">
                        <select class="sort-select" name="sort" id="sort" onChange="send()">
                            <option value="latest">최신순</option>
                            <option value="name">가나다순</option>
                            <option value="view">조회수순</option>
                            <option value="like">좋아요순</option>
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
                                    <div class="recipe-card">
                                        <img src="${pageContext.request.contextPath}${recipe.thumbnail}" />
                                        <div class="recipe-info">
                                            <div class="recipe-title">${recipe.title}(${recipe.food_name})</div>
                                            <div class="recipe-meta">
                                                ⏱ ${recipe.cooking_time} &nbsp;&nbsp; 등록일자: ${recipe.created_date}
                                                <br>
                                                👁 ${recipe.view_count} &nbsp;&nbsp; 
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%-- 페이징 --%>
                    <c:if test="${totalPage > 0}">
                        <div class="paging">
                            <c:set var="curPage" value="${empty recipeSearchDTO.page ? 1 : recipeSearchDTO.page}" />

                            <%-- 1. 반복되는 cookTimes 쿼리 스트링을 밖에서 미리 변수로 만들어두기 --%>
                            <c:set var="cookTimesQuery" value="" />
                            <c:if test="${not empty recipeSearchDTO.cookTimes}">
                                <c:forEach var="t" items="${recipeSearchDTO.cookTimes}">
                                    <c:set var="cookTimesQuery" value="${cookTimesQuery}&cookTimes=${t}" />
                                </c:forEach>
                            </c:if>

                            <%-- 2. 이전 버튼 (미리 만든 cookTimesQuery를 concat으로 붙이기) --%>
                            <a href="${curPage > 1 ? '/recipe_list.do?page='.concat(curPage - 1).concat('&category=').concat(recipeSearchDTO.category).concat(cookTimesQuery) : '#'}" class="arrow ${curPage == 1 ? 'disabled' : ''}">◀</a>

                            <c:set var="startP" value="${curPage - 1 < 1 ? 1 : (curPage == totalPage and totalPage >= 3 ? totalPage - 2 : curPage - 1)}" />
                            <c:set var="endP" value="${startP + 2 > totalPage ? totalPage : startP + 2}" />
                            
                            <c:if test="${totalPage < 1}">
                                <c:set var="startP" value="1" />
                                <c:set var="endP" value="1" />
                            </c:if>

                            <%-- 3. 페이지 번호 (여기도 cookTimesQuery 변수 사용) --%>
                            <c:forEach var="i" begin="${startP}" end="${endP}">
                                <a href="/recipe_list.do?page=${i}&category=${recipeSearchDTO.category}${cookTimesQuery}" class="${i == curPage ? 'active' : ''}">
                                    ${i}
                                </a>
                            </c:forEach>

                            <%-- 4. 다음 버튼 --%>
                            <a href="${curPage < totalPage ? '/recipe_list.do?page='.concat(curPage + 1).concat('&category=').concat(recipeSearchDTO.category).concat('&sort=').concat(currentSort).concat(cookTimesQuery) : '#'}" class="arrow ${curPage == totalPage || totalPage <= 1 ? 'disabled' : ''}">▶</a>
                        </div>
                    </c:if>
                </section>
            </div>
        </form>
    </form>
</body>
</html>