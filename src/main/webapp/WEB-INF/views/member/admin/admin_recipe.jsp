<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <head>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_recipe.css" />

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

                function statusText(status) {
                    if (status === "ACTIVE") {
                        return "공개";
                    }
                    if (status === "HIDDEN") {
                        return "비공개";
                    }
                    if (status === "DELETE") {
                        return "삭제";
                    }
                    return status || "";
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
                    setText("status", statusText(recipe.status));

                    setImg("model_img", "/upload/recipe/" + recipe.thumbnail);

                    document.querySelector(".btn-private").value =
                        recipe.status === "ACTIVE"
                            ? "비공개 전환"
                            : "공개 전환";

                    document.querySelector(".btn-delete").value =
                        recipe.status === "DELETE"
                            ? "복원 하기"
                            : "삭제 하기";

                    document.querySelector(".btn-recommend").value =
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

                            if (data.result == 1 && data.status == "DELETE") {
                                alert(data.title + "가 삭제되었습니다.");
                            } else if (data.result == 1 && data.status == "ACTIVE") {
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

                // 추천 레시피 등록/ 해제
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

                // 레시피 수정 함수
                function recipemodify(){
                    location.href="/recipe_update.do?recipeId="+recipedetailrecipe;
                }
                
            </script>
        </head>
        <section class="ra-wrap">
            <div class="ra-main">

                <div class="ra-content">

                    <div class="ra-header">
                        <div class="ra-title-box">
                            <h3 class="ra-title">레시피 관리</h3>
                            <p class="ra-desc">등록된 레시피를 관리하고 추천 레시피를 설정할수 있습니다.</p>
                        </div>
                    </div>

                    <div class="ra-tabs">
                        <input class="ra-tab" type="button" value="전체 레시피" onclick="location.href='/admin/recipe'" />
                        <input class="ra-tab" type="button" value="추천 레시피"
                            onclick="location.href='/admin/recipe?recommend=true'" />
                    </div>

                    <form action="/admin/recipe" method="get">

                        <input type="hidden" name="page" value="1" />
                        <input type="hidden" name="recommend" value="${searchrecipe.recommend}" />

                        <div class="ra-filter">

                            <input id="keyword" type="text" class="ra-search" name="keyword" placeholder="레시피명, 작성자명 검색"
                                value="${searchrecipe.keyword}" onkeydown="eneterSearch(event)" />

                            <select id="category" class="ra-category" name="category_name" onchange="searchRecipe()">
                                <option value="">카테고리 전체</option>
                                <option value="recommend" ${searchrecipe.category_name eq 'recommend' ? 'selected' : ''
                                    }>상황별 추천</option>
                                
                                <option value="korean" ${searchrecipe.category_name eq 'korean' ? 'selected' : '' }>한식
                                </option>
                                <option value="western" ${searchrecipe.category_name eq 'western' ? 'selected' : '' }>양식
                                </option>
                                <option value="chinese" ${searchrecipe.category_name eq 'chinese' ? 'selected' : '' }>중식
                                </option>
                                <option value="japanese" ${searchrecipe.category_name eq 'japanese' ? 'selected' : '' }>
                                    일식</option>
                                <option value="asian" ${searchrecipe.category_name eq 'asian' ? 'selected' : '' }>아시안
                                </option>
                                <option value="healthy" ${searchrecipe.category_name eq 'healthy' ? 'selected' : '' }>
                                    건강식/다이어트</option>
                                <option value="quick" ${searchrecipe.category_name eq 'quick' ? 'selected' : '' }>초간단 요리
                                </option>
                                <option value="dessert" ${searchrecipe.category_name eq 'dessert' ? 'selected' : '' }>
                                    디저트</option>
                                <option value="baking" ${searchrecipe.category_name eq 'baking' ? 'selected' : '' }>베이킹
                                </option>
                                <option value="beverage" ${searchrecipe.category_name eq 'beverage' ? 'selected' : '' }>
                                    음료/차</option>
                            </select>

                            <select id="status" class="ra-status" name="status" onchange="searchRecipe()">
                                <option value="">공개/비공개</option>
                                <option value="ACTIVE" ${searchrecipe.status eq 'ACTIVE' ? 'selected' : '' }>공개
                                </option>
                                <option value="HIDDEN" ${searchrecipe.status eq 'HIDDEN' ? 'selected' : '' }>비공개
                                </option>
                                
                            </select>

                            <button type="button" class="ra-reset" onclick="resetSearch()">
                                <img src="/images/reset.png"/>
                            </button>

                        </div>

                        <div id="recipeResultArea">
                            <table class="ra-table">
                                <tr>
                                    <th>썸네일</th>
                                    <th>레시피 제목</th>
                                    <th>작성자</th>
                                    <th>등록일</th>
                                    <th>조회수</th>
                                    <th>상태</th>
                                    <th>관리</th>
                                </tr>
                                <tbody id="recipeTableBody">
                                    <!-- forEach문 들어갈 예정 -->
                                    <c:forEach var="recipe" items="${list}">
                                        <tr class="ra-row" onclick="recipe_view('${recipe.recipe_id}')">
                                            <td><img class="ra-thumb" src="/upload/recipe/${recipe.thumbnail}" /></td>
                                            <td class="ra-info">
                                                <div class="ra-name">                                                    
                                                    ${recipe.title}
                                                </div>
                                                <small class="ra-category-label">${recipe.category_name}</small>
                                            </td>
                                            <td>${recipe.nickname}</td>
                                            <td>${recipe.created_date}</td>
                                            <td>${recipe.view_count}</td>
                                            <td>
                                                <c:if test="${recipe.status eq 'ACTIVE'}">
                                                    <span class="badge badge-public">공개</span>
                                                </c:if>

                                                <c:if test="${recipe.status eq 'HIDDEN'}">
                                                    <span class="badge badge-private">비공개</span>
                                                </c:if>

                                                <c:if test="${recipe.status eq 'DELETE'}">
                                                    <span class="badge badge-delete">삭제</span>
                                                </c:if>
                                            </td>
                                            <td>...</td>
                                        </tr>

                                    </c:forEach>
                                    <!--  -->
                                </tbody>
                            </table>

                            <div class="ra-footer">
                                <span class="ra-total">전체 갯수: ${totalcount}</span>
                                <div class="ra-page" id="recipePaging">
                                    <c:set var="pageUrl"
                                        value="/admin/recipe?keyword=${searchrecipe.keyword}&category_name=${searchrecipe.category_name}&status=${searchrecipe.status}&recommend=${searchrecipe.recommend}"
                                        scope="request" />
                                    <jsp:include page="/WEB-INF/views/common/paging.jsp" />
                                </div>

                                <input type="button" class="ra-add-btn" value="레시피 등록" onclick="" />

                            </div>
                        </div>
                    </form>
                </div>

                <!-- 레시피 상세보기 모달로 구현 -->
                <div class="ra-detail">

                    <div class="ra-detail-head">
                        <h4>레시피 상세 정보</h4>
                        <button type="button" class="ra-close" onclick="closeDetail()">x</button>
                    </div>


                    <img id="model_img" class="ra-cover" src="/upload/recipe/" />


                    <div class="ra-title-box">
                        <h3 id="model-title"></h3>

                        <dl class="ra-meta">

                            <dt>작성자</dt>
                            <dd id="model-nickname"></dd>

                            <dt>카테고리</dt>
                            <dd id="model-category"></dd>

                            <dt>등록일</dt>
                            <dd id="model-created"></dd>

                            <dt>수정일</dt>
                            <dd id="model-modify"></dd>

                            <dt>조회수</dt>
                            <dd id="model-count"></dd>
    
                            <dt>상태</dt>
                            <dd id="model-status"></dd>

                        </dl>

                    </div>

                    <div class="ra-steps">
                        <h4>조리과정</h4>

                        <div id="cookOrderBox">
                        </div>


                    </div>
                    <div class="ra-actions">
                        <input type="button" class="btn-edit" value="수정 하기" onclick="recipemodify()" />                        
                        <input type="button" class="btn-private" value="" onclick="recipeprivate(this)" />
                        <input type="button" class="btn-delete" value="" onclick="recipedel(this)" />
                        <input type="button" class="btn-recommend" value="" onclick="reciperecommend(this)" />
                    </div>
                </div>
        </section>
