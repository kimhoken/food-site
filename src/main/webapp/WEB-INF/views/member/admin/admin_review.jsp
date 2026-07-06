<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <head>

            <script>
                let selreview;

                function entersearch(e) {

                    if (e.key === "Enter") {
                        searchreview();
                    }

                }

                function searchreview() {
                    document.querySelector('form[action="/admin/review"]').submit();
                }

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

                function filereview(dto) {
                    setImg("model-image","/upload/review/"+dto.image);
                    setText("title", dto.title);
                    setText("user", dto.nickname);
                    setText("content", dto.content);                
                    setText("created", dto.created_at);
                    setText("status", dto.status);
                    setText("rating", dto.rating);
                    setText("view", dto.view_count);

                    document.querySelector(".re-btn-hidden").value = '공개 전환';
                    document.querySelector(".re-btn-delete").value = '삭제';

                    if (dto.status === 'HIDDEN') {
                        document.querySelector(".re-btn-hidden").value = '비공개 전환'
                    }

                    if (dto.status === 'DELETE') {
                        document.querySelector(".re-btn-delete").value = '복원'
                    }
                }

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
                                <option value="">정렬</option>
                                <option value="asc">오름차순</option>
                                <option value="desc">내림차순</option>
                                <option value="view">조회수순</option>
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
                                        <img src="/upload/review/${review.image}" />
                                        <span>${review.main_title}</span>
                                    </td>

                                    <td>${review.content}</td>
                                    <td>${review.rating}</td>
                                    <td>${review.nickname}</td>
                                    <td>${review.created_at}</td>
                                    <td>${review.status}</td>

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
