<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <!DOCTYPE html>
        <html>

        <head>
            <title>오늘 뭐 먹지? - 레시피 공유</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/board.css" />
            <link rel="stylesheet" href="/css/main.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search_bar.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/review.css"/>
            <link rel="stylesheet" href="/css/chatbot.css" />
            <script src="/js/chatbot.js"></script>
            <script src="${pageContext.request.contextPath}/js/util.js"></script>
            <script>
                document.addEventListener("DOMContentLoaded", function () {
                    // 1. 검색창 드롭다운 로직
                    const searchInput = document.getElementById("mainSearch");
                    const searchDropdown = document.getElementById("searchDropdown");

                    searchInput.addEventListener("focus", function () {
                        searchDropdown.style.display = "block";
                    });

                    document.addEventListener("click", function (event) {
                        if (!searchInput.contains(event.target) && !searchDropdown.contains(event.target)) {
                            searchDropdown.style.display = "none";
                        }
                    });

                    // 2. 컨트롤러에서 넘어온 모델 값 세팅 (빈 값일 경우 기본값 설정)
                    const sort = "${sort}"
                    if (sort == '') {
                        console.log("123")
                        sort = "latest";
                    }
                    const period = "${period}";
                    const btnValue = "${btn}";

                    // 3. Select Box (최신순/인기순/별점) 상태 유지
                    let select = document.getElementById("mainSortSelect");
                    if (select) {
                        select.value = sort;
                    }

                    // 4. 인기순(popular)일 경우 서브탭(주간/월간) 상태 유지
                    const subTabs = document.getElementById("popularSubTabs");
                    if (sort === "popular") {
                        subTabs.classList.add("show");

                        const buttons = document.querySelectorAll(".sub-tab-btn");
                        buttons.forEach(btn => btn.classList.remove("active"));

                        if (period === 'weekly') {
                            buttons[1].classList.add("active");
                        } else if (period === 'monthly') {
                            buttons[2].classList.add("active");
                        } else {
                            buttons[0].classList.add("active"); // 전체기간
                        }
                    }

                    // 5. 탭(자유게시판 vs 리뷰) 상태 유지 
                    if (btnValue === "review") {
                        changeState(2);
                    } else {
                        changeState(1);
                    }
                });

                function send(f) {
                    f.submit();
                }

                /* 4. 승연추가 */
                //레시피 후기 최신순, 인기순, 별점
                function handleMainSort(sortValue) {
                    const subTabs = document.getElementById("popularSubTabs");

                    //  인기순(popular)을 골랐을 때만 서브탭 보여주기
                    if (sortValue === "popular") {
                        subTabs.classList.add("show");
                        fetchReviewData("popular", "all");
                    } else {
                        // 최신순이나 별점 높은순으로 돌아가면 서브탭을 다시 숨긴다
                        subTabs.classList.remove("show");
                        resetSubTabs();
                        fetchReviewData(sortValue, null);
                    }
                }
                /* 5. 승연추가 */
                //[전체기간], [주간], [월간] 중 하나를 클릭했을 때 실행
                function changePeriod(periodValue, event) {
                    const buttons = document.querySelectorAll(".sub-tab-btn");
                    buttons.forEach(btn => btn.classList.remove("active"));
                    event.target.classList.add("active");
                    fetchReviewData("popular", periodValue);
                }
                /* 6. 승연추가 */
                //서브탭들의 선택 상태를 맨 처음 상태([전체기간])로 초기화
                function resetSubTabs() {
                    const buttons = document.querySelectorAll(".sub-tab-btn");
                    buttons.forEach((btn, index) => {
                        if (index === 0) btn.classList.add("active");
                        else btn.classList.remove("active");
                    });
                }
                /* 7. 승연추가 */
                // 드롭다운,서브탭이 바뀔 때마다 데이터 비동기(?)로 요청
                function fetchReviewData(sort, period) {
                    location.href = "/list.do?sort=" + sort + "&period=" + (period == null ? "null" : period) + "&btn=review";
                }
                /* --------- 06-25 수정  ---------*/
                /**
                 * 버튼 클릭시 상태 변경하는거 한번에 관리
                */
                const changeState = (btn) => {

                    let board = document.getElementById("boardArea");
                    let review = document.getElementById("reviewArea");
                    let reviewList = document.getElementById("reviewFeedList");
                    //버튼 클릭으로 디스플레이 조정
                    if (btn === 1) {

                        board.style.display = "block";
                        review.style.display = "none";

                        reviewList.style.display = "none";

                        document.getElementById("boardBtn").classList.add("active");
                        document.getElementById("reviewBtn").classList.remove("active");
                    } else {
                        board.style.display = "none";
                        review.style.display = "block"

                        reviewList.style.display = "flex";

                        document.getElementById("boardBtn").classList.remove("active");
                        document.getElementById("reviewBtn").classList.add("active");
                    }
                }

                function toggleReviewModal(card, review_id) {
                    const isOpen = card.classList.contains("open");

                    document.querySelectorAll(".review-card.open").forEach(item => {
                        item.classList.remove("open");
                    });

                    if (!isOpen) {
                        card.classList.add("open");
                    }

                    fetch("/review/detail",{
                        method:'post',
                        headers: {"Content-Type": "application/x-www-form-urlencoded"},
                        body: "review_id="+review_id
                    }).then(res=> res.json())
                    .then(dto => {
                        console.log(dto);

                        setModal(dto, card);

                        const viewspan = card.querySelector(".review-views");
                        if (viewspan) {
                            viewspan.textContent = "조회수 "+ dto.view_count;
                        }

                        const ownerbtn = card.querySelector(".owner-btn");
                        const guestbtn = card.querySelector(".guest-btn");
                        if (dto.owner) {
                            ownerbtn.style.display="block";
                        } else {
                            guestbtn.style.display="block";
                        }
                    })

                }

                function setModal(dto, card){

                    const imagePath = dto.thumbnail ? "/upload/review/" + dto.thumbnail 
                                                    : "/upload/recipe/" + dto.recipe_thumbnail;


                    setImg("model-img", imagePath, card);
                    setText("recipetitle",dto.recipe_title, card);
                    setText("title",dto.title, card);
                    setText("content", dto.content, card);
                    setText("rating", dto.rating, card);
                    setImgs("model-imgs",dto.imgList, card);
                    setA("tag","/recipe_detail.do?recipe_id="+dto.recipe_id, card);

                }

                function closeReviewModal(button) {
                    button.closest(".review-card").classList.remove("open");
                }

                function deleteReview(review_id){

                    if(!confirm("삭제 하시겠습니까?")) {
                        return;
                    }

                    fetch("/review/delete",{
                        method:'post',
                        headers:{"Content-Type": "application/x-www-form-urlencoded"},
                        body:"review_id="+review_id
                    }).then(res => res.json())
                    .then(data => {
                        if( data.result > 0 ){
                            alert( data.title + "삭제 되었습니다.");
                            location.reload();
                        } else {
                            alert( "삭제가 되지 않았습니다." );
                        }
                    })

                }

                function openImageModal(src){

                    document.getElementById("imageModalImg").src=src;
                    document.getElementById("imageModal").classList.add("show");
                }    

                function closeImageModal(){
                    
                    document.getElementById("imageModal").classList.remove("show");
                }    

            </script>
        </head>

        <body>
            <jsp:include page="/WEB-INF/views/common/navibar.jsp">
                <jsp:param name="currentMenu" value="community" />
            </jsp:include>

            <!-- 커뮤니티 헤더 -->
            <div class="community-header-frame">
                <div class="community-title-box">
                    <h1>커뮤니티</h1>
                    <h2>소소한 요리 일상과 생생한 레시피 후기를 나누는 공간</h2>
                </div>
                <!-- 커뮤니티 들어왔을 때 게시판(기본값) 먼저 보여지게 하기-->
                <div class="community-menu">
                    <button id="boardBtn" class="community-btn ${btn eq 'board' ? 'active' : ''}"
                        onclick="changeState(1)">
                        게시판 전체보기
                    </button>
                    <button id="reviewBtn" class="community-btn ${btn eq 'review' ? 'active' : ''}"
                        onclick="changeState(2)">
                        최근 레시피 후기
                    </button>
                </div>
            </div>

            <!-- 게시판 -->
            <div class="board-area" id="boardArea" style="display:none;">
                <c:if test="${not empty list}">
                    <table>
                        <thead>
                            <tr>
                                <th>게시글 번호</th>
                                <th>닉네임</th>
                                <th>제목</th>
                                <th>조회수</th>
                                <th>작성일</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="board" items="${list}">
                                <tr>
                                    <td>${board.board_id}</td>
                                    <td>${board.nickname}</td>
                                    <td>
                                        <a href="/view.do?board_id=${board.board_id}">
                                            ${board.title}
                                        </a>
                                    </td>
                                    <td>${board.view_count}</td>
                                    <td>${board.created_date}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
                <c:if test="${empty list}">
                    <h3 align="center">"${searchWord}"에 대한 검색 결과가 없습니다 :( </h3>
                </c:if>
                <%-- 로그인 한 경우만 버튼이 보이게 --%>
                    <c:if test="${!empty sessionScope.user}">
                        <div style="text-align:center; margin-top:20px;">
                            <input type="button" class="community-write-btn"
                                   value="나도 끄적끄적 ✍️" onclick="location.href='/community_form.do'"/>
                        </div>
                    </c:if>
                    <!-- 페이징 처리 -->
                    <div class="board-page-box">
                        <c:if test="${paging.prev}">
                            <a href="/list.do?page=${paging.startpage - 1}&btn=board">◀</a>
                        </c:if>

                        <c:forEach var="p" begin="${paging.startpage}" end="${paging.endpage}">
                            <a href="/list.do?page=${p}&btn=board"
                            class="${paging.page eq p ? 'active' : ''}">
                                ${p}
                            </a>
                        </c:forEach>

                        <c:if test="${paging.next}">
                            <a href="/list.do?page=${paging.endpage + 1}&btn=board">▶</a>
                        </c:if>

                    </div>
            </div>            
            <!-- 최근 레시피 후기 -->
            <div class="review-area" id="reviewArea" style="display:none;">
                <div class="review-filter-wrap">
                    <div class="filter-controls">
                        <div id="popularSubTabs" class="sub-tabs">
                            <button type="button" class="sub-tab-btn active"
                                onclick="changePeriod('all', event)">전체기간</button>
                            <button type="button" class="sub-tab-btn"
                                onclick="changePeriod('weekly', event)">주간</button>
                            <button type="button" class="sub-tab-btn"
                                onclick="changePeriod('monthly', event)">월간</button>
                        </div>
                        <select id="mainSortSelect" class="sort-dropdown" onchange="handleMainSort(this.value)">
                            <option value="all">정렬기준</option>
                            <option value="latest">최신순</option>
                            <option value="popular">조회수 순</option>
                            <option value="rating">별점</option>
                        </select>
                    </div>
                </div>
            </div>
            <!-- 후기 리스트들 -->
            <div id="reviewFeedList" class="review-feed-list">
                <c:forEach var="review" items="${reviewList}">
                    <div class="review-card" onclick="toggleReviewModal(this, '${review.review_id}')">

                        <div class="review-card-main">

                            <div class="review-card-image">
                                <c:choose>
                                    <c:when test="${not empty review.thumbnail}">
                                        <img src="/upload/review/${review.thumbnail}" alt="후기 이미지">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="/upload/recipe/${review.recipe_thumbnail}" alt="레시피 이미지">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="review-card-content">
                                <div class="review-info-top">
                                    <h3 class="review-title">
                                        ${review.title}
                                    </h3>
                                    <span class="review-rating">[★ ${review.rating}]</span>
                                </div>
                                <div class="review-info-meta">
                                    <span class="review-nickname">${review.nickname}</span>
                                    <span class="review-divider">•</span>
                                    <span class="review-views">조회수 ${review.view_count}</span>
                                </div>
                                <p class="review-body">
                                    ${review.content}
                                </p>
                            </div>
                        </div>

                        <div class="review-expand-box" onclick="event.stopPropagation()">
                            <a id="model-tag" href="#">
                                <div>
                                    <img id ='model-img' class="model-img"/>
                                </div>
                                <h4 id="model-recipetitle">레시피 이름</h4>
                            </a>
                            <div id="model-rating" class="model-rating">평점</div>
                            
                            <p id="model-content" class="model-content"></p>
                            <div id="model-imgs" class="model-imgs">이미지 나열</div>
                                                       
                            <div class="review-model-btn">
                               
                                <div class="owner-btn" style="display: none;">
                                    <input type="button" 
                                           value="수정" 
                                           onclick="location.href='/review/modify?review_id=${review.review_id}'" />
                                    <input type="button" value="삭제" onclick="deleteReview('${review.review_id}')" />
                                </div>

                                <div class="guest-btn" style="display: none;">
                                    <input type="button" 
                                           value="신고" 
                                           onclick="location.href='/report/form.do?review_id=${review.review_id}'" />
                                </div>
                        
                               

                            </div>

                        </div>

                    </div>
                </c:forEach>
                
                <div class="review-page-box">

                    <c:if test="${reviewPaging.prev}">
                        <a href="/list.do?page=${reviewPaging.startpage - 1}&btn=review&sort=${sort}&period=${period}">◀</a>
                    </c:if>

                    <c:forEach var="p" begin="${reviewPaging.startpage}" end="${reviewPaging.endpage}">
                        <a href="/list.do?page=${p}&btn=review&sort=${sort}&period=${period}"
                        class="${reviewPaging.page eq p ? 'active' : ''}">
                            ${p}
                        </a>
                    </c:forEach>

                    <c:if test="${reviewPaging.next}">
                        <a href="/list.do?page=${reviewPaging.endpage + 1}&btn=review&sort=${sort}&period=${period}">▶</a>
                    </c:if>

                </div>
            </div>
            <jsp:include page="/WEB-INF/views/common/footer.jsp" />
            <!-- 챗봇 -->
            <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />

            <div id="imageModal" class="image-modal" onclick="closeImageModal()">
                <img id="imageModalImg" class="image-modal-img"/>
            </div>
        </body>
</html>
