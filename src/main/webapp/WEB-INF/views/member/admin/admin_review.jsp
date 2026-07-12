<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <head>

            <script>
                let selreview;

                //엔터시 검색
                function entersearch(e) {

                    if (e.key === "Enter") {
                        searchreview();
                    }

                }

                // 검색시 폼으로 전송
                function searchreview() {
                    document.querySelector('form[action="/admin/review"]').submit();
                }

                // 상태 설정 함수
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

                //  후기 상세 보기 
                function review_view(review_id) {

                    fetch("/admin/review/view", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: 'review_id=' + review_id
                    }).then(res => res.json())
                        .then(dto => {
                            console.log(dto);

                            filereview(dto);

                            selreview = dto.review_id;

                            // 회원 정지 상태 변경 함수
                            document.querySelector(".re-btn-hidden").onclick =
                                () => reviewhidden(dto.review_id);
                            // 신고 내역 보려 가는 함수 추가할 예정
                            document.querySelector(".re-btn-delete").onclick =
                                () => reviewdelete(dto.review_id);
                            document.querySelector(".ma-detail-panel").classList.add("active");
                        })
                }

                // 후기 모달 설정
                function filereview(dto) {

                    const imagePath = dto.thumbnail ? "/upload/review/" + dto.thumbnail 
                                                    : "/upload/recipe/" + dto.recipe_thumbnail;

                    setImg("model-image", imagePath);
                    setText("title", dto.title);
                    setText("user", dto.nickname);
                    setText("content", dto.content);                
                    setText("created", dto.created_at);
                    setText("status", statusText(dto.status));
                    setText("rating", dto.rating);
                    setText("view", dto.view_count);

                    document.querySelector(".model-status").value = "공개";
                    document.querySelector(".re-btn-hidden").value = '공개 전환';
                    document.querySelector(".re-btn-delete").value = '삭제';

                    if (dto.status === 'HIDDEN') {
                        document.querySelector(".model-status").value = "비공개";
                        document.querySelector(".re-btn-hidden").value = '비공개 전환'
                    }

                    if (dto.status === 'DELETE') {
                        document.querySelector(".model-status").value = "삭제";
                        document.querySelector(".re-btn-delete").value = '복원'
                    }
                }

                // 후기 상태 ( 공개/비공개 ) 변경 
                function reviewhidden() {                    
                    fetch("/admin/review/hidden", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: 'review_id=' + selreview
                    })
                        .then(res => res.json())
                        .then(data => {
                            if (data.result > 0 && data.status === 'HIDDEN') {
                                alert("비공개 처리 되었습니다.");
                            } else if (data.result > 0 && data.status === 'ACTIVE') {
                                alert("공개 처리 되었습니다.");
                            } else{
                                alert("공개 / 비공개 전환을 할수 없습니다.");
                            }
                        })
                }

                // 후기 삭제 / 복원 기능 
                function reviewdelete() {

                    fetch("/admin/review/delete", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: 'review_id=' + selreview
                    })
                        .then(res => res.json())
                        .then(data => {
                            if (data.result > 0 && data.status === 'DELETE') {
                                alert("삭제 되었습니다.");
                            } else if (data.result > 0 && data.status === 'ACTIVE') {
                                alert("복원 되었습니다.");
                            } else{
                                alert("이스터에그");
                            }
                        })
                }

                // 상세 모달 닫기
                function closeReviewDetail() {
                    document.querySelector(".ma-detail-panel").classList.remove("active");
                }
                

            </script>

        </head>

        <section class="admin-list-page admin-review-page">

            <div>

                <form action="/admin/review" method="get">

                    <div>
                        
                        <div>
                            <h3>레시피 후기 관리 페이지</h3>
                            <small>회원들의 레시피 후기을 관리 할수 있습니다.</small>
                        </div>

                        <div>
                            <input type="text" placeholder="게시글, 작성자를 입력하세요" name="keyword"
                                onkeydown="entersearch(event)" />

                            <select name="sort" onchange="searchreview()">
                                <option value="" >정렬</option>
                                <option value="oldest" ${adminreview.sort eq 'oldest' ? 'selected' : '' }>오름차순</option>
                                <option value="latest" ${adminreview.sort eq 'latest' ? 'selected' : '' }>내림차순</option>
                                <option value="view" ${adminreview.sort eq 'view' ? 'selected' : '' }>조회수순</option>
                            </select>

                            <select name="status" onchange="searchreview()">
                                <option value="">상태</option>
                                <option value="ACTIVE" ${adminreview.status eq 'ACTIVE' ? 'selected' : ''}>공개</option>
                                <option value="HIDDEN" ${adminreview.status eq 'HIDDEN' ? 'selected' : ''}>숨김</option>
                                <option value="DELETE" ${adminreview.status eq 'DELETE' ? 'selected' : ''}>삭제</option>
                            </select>


                        </div>

                        <table>

                            <tr>

                                <th>레시피명</th>
                                <th>후기내용</th>
                                <th>평점</th>
                                <th>작성자</th>
                                <th>등록일</th>
                                <th>상태</th>

                            </tr>

                            <c:forEach var="review" items="${list}">

                                <tr onclick="review_view('${review.review_id}')">

                                    <td>
                                        <c:choose>

                                            <c:when test="${not empty review.thumbnail}">
                                                <img src="/upload/review/${review.thumbnail}" />
                                            </c:when>

                                            <c:otherwise>
                                                <img src="/upload/recipe/${review.recipe_thumbnail}" />
                                            </c:otherwise>

                                        </c:choose>
                                        <span>${review.main_title}</span>
                                    </td>

                                    <td>${review.content}</td>
                                    <td>${review.rating}</td>
                                    <td>${review.nickname}</td>
                                    <td>${review.created_at}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${review.status eq 'ACTIVE'}">공개</c:when>
                                            <c:when test="${review.status eq 'HIDDEN'}">비공개</c:when>
                                            <c:when test="${review.status eq 'DELETE'}">삭제</c:when>
                                            <c:otherwise>${review.status}</c:otherwise>
                                        </c:choose>
                                    </td>

                                </tr>

                            </c:forEach>

                        </table>

                        <div>

                            <div>총 게시글: ${totalcount}</div>

                            <div>

                                <c:set var="pageUrl"
                                    value="/admin/review?keyword=${adminreview.keyword}&status=${adminreview.status}&sort=${adminreview.sort}"
                                    scope="request" />

                                <jsp:include page="/WEB-INF/views/common/paging.jsp" />

                            </div>

                        </div>

                    </div>

                </form>

                <!-- 상세 모달 부분 -->
                <div class="ma-detail-panel">
                    <div class="ma-detail-header">
                        <button type="button" class="ra-close" onclick="closeReviewDetail()">x</button>
                        <h3>후기 상세</h3>
                    </div>

                    <dl class="ma-detail-list">

                        <dt>대상 레시피</dt>
                        <dd id="model-title" class="model-recipe"></dd>

                        <dt>썸네일</dt>
                        <dd class="model-thumbnail">
                            <img id="model-image"/>
                        </dd>

                        <dt>작성자</dt>
                        <dd id="model-user" class="model-user"></dd>

                        <dt>작성일</dt>
                        <dd id="model-created" class="model-date"></dd>

                        <dt>평점</dt>
                        <dd id="model-rating" class="model-rating"></dd>

                        <dt>상태</dt>
                        <dd id="model-status" class="model-status"></dd>
                        
                        <dt>조회수</dt>
                        <dd id="model-view" class="model-view"></dd>

                        <dt>후기 내용</dt>
                        <dd id="model-content" class="model-content"></dd>
                    </dl>

                    <div class="re-action">

                        <input type="button" class="re-btn re-btn-hidden" value="" onclick="" />
                        <input type="button" class="re-btn re-btn-delete" value="신고 내역 보기" onclick="" />
                        
                    </div>

                </div>

            </div>

        </section>
