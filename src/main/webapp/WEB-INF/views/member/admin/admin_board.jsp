<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <head>
            <script>

                let selboard;

                // 검색어 입력 후 언터키 누르면 검색
                function entersearch(e) {

                    if (e.key === "Enter") {
                        searchboard();
                    }

                }

                // 현재 검색/필터 조건으로 목록 조회 폼을 제출
                function searchboard() {
                    document.querySelector('form[action="/admin/board"]').submit();
                }

                // 상태 코드를 화면에 표시할 한글 문구로 변환
                function statusText(status) {
                    if (status === "ACTIVE") {
                        return "\uACF5\uAC1C";
                    }
                    if (status === "HIDDEN") {
                        return "\uBE44\uACF5\uAC1C";
                    }
                    if (status === "DELETE") {
                        return "\uC0AD\uC81C";
                    }
                    return status || "";
                }

                // 상세 패널을 닫고 선택 상태를 해제
                function board_view(board_id) {
                    fetch("/admin/board/view", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: 'board_id=' + board_id
                    }).then(res => res.json())
                        .then(dto => {
                            console.log(dto);

                            fileboard(dto);

                            selboard = dto.board_id;

                            // 회원 정지 상태 변경 함수
                            document.querySelector(".bd-btn-hidden").onclick =
                                () => boardhidden(dto.board_id);
                            // 신고 내역 보려 가는 함수 추가할 예정
                            document.querySelector(".bd-btn-delete").onclick =
                                () => boarddelete(dto.board_id);
                            document.querySelector(".bd-detail-panel").classList.add("active");
                        })
                }

                // 상세 모달에 데이터 채움
                function fileboard(dto) {
                    setText("title", dto.title);
                    setText("user", dto.nickname);
                    setText("type", dto.board_type);
                    setText("content", dto.content);
                    setText("view", dto.view_count);
                    setText("comment", dto.comment_count);
                    setText("created", dto.created_date);
                    setText("update", dto.updated_date);
                    setText("status", statusText(dto.status));

                    // 상태에 따라 상태 출력( 'ACTIVE' 면 공개)
                    document.querySelector(".bd-btn-hidden").value = '공개 전환';
                    document.querySelector(".bd-btn-delete").value = '삭제';
                    
                    if (dto.status === 'HIDDEN') {
                        document.querySelector(".bd-btn-hidden").value = '비공개 전환'
                    }

                    if (dto.status === 'DELETE') {
                        document.querySelector(".bd-btn-delete").value = '복원'
                    }
                }

                // 게시글 공개/비공개 변환
                function boardhidden() {                    
                    fetch("/admin/board/hidden", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: 'board_id=' + selboard
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

                // 게시글 삭제/복원
                function boarddelete() {
                    fetch("/admin/board/delete", {
                        method: 'post',
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: 'board_id=' + selboard
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

                // 상세 모달 닫기 함수
                function closeBoardDetail() {
                    document.querySelector(".bd-detail-panel").classList.remove("active");
                }

            </script>
        </head>
        <section class="admin-list-page admin-board-page">
            <div>
                <div>
                    <h3>게시글 관리 페이지</h3>
                    <small>회원들의 게시글을 관리 할수 있습니다.</small>
                </div>
                <div>
                    <form action="/admin/board" method="get">
                        <div>
                            <input type="text" placeholder="게시글, 작성자를 입력하세요" name="keyword"
                                onkeydown="entersearch(event)" />

                            <select name="sort" onchange="searchboard()">

                                <option value="">정렬</option>
                                <option value="latest" ${adminboard.sort eq 'latest' ? 'selected' : ''}>최신순</option>
                                <option value="oldest" ${adminboard.sort eq 'oldest' ? 'selected' : ''}>오래된순</option>
                                <option value="view" ${adminboard.sort eq 'view' ? 'selected' : ''}>조회순</option>

                            </select>

                        </div>

                        <!-- 게시글 목록 출력 -->
                        <table>
                            <tr>
                                <th>제목</th>
                                <th>작성자</th>
                                <th>댓글수</th>
                                <th>조회수</th>
                                <th>등록일</th>
                                <th>상태</th>
                            </tr>
                            <c:forEach var="board" items="${list}">

                                <tr onclick="board_view('${board.board_id}')">
                                    <td>                                        
                                        <span>${board.title}</span>
                                    </td>
                                    <td>${board.nickname}</td>
                                    <td>${board.comment_count}</td>
                                    <td>${board.view_count}</td>
                                    <td>${board.created_date}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${board.status eq 'ACTIVE'}">&#44277;&#44060;</c:when>
                                            <c:when test="${board.status eq 'HIDDEN'}">&#48708;&#44277;&#44060;</c:when>
                                            <c:when test="${board.status eq 'DELETE'}">&#49325;&#51228;</c:when>
                                            <c:otherwise>${board.status}</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>

                            </c:forEach>
                        </table>

                        <div>
                            <div>총 게시글: ${totalcount}</div>
                            <div>
                                <c:set var="pageUrl"
                                    value="/admin/board?keyword=${adminboard.keyword}&status=${adminboard.status}&sort=${adminboard.sort}"
                                    scope="request" />
                                <jsp:include page="/WEB-INF/views/common/paging.jsp" />
                            </div>
                        </div>
                    </form>

                </div>
                
                <!-- 상세 모달 출력 -->
                <div class="bd-detail-panel">
                    <div class="bd-detail-header">
                        <button type="button" class="ra-close" onclick="closeBoardDetail()">x</button>
                        <h3>게시글 상세</h3>
                    </div>

                    <dl class="bd-detail-list">

                        <dt>제목</dt>
                        <dd id="model-title" class="model-title"></dd>

                        <dt>작성자</dt>
                        <dd id="model-user" class="model-user"></dd>

                        <dt>카테고리</dt>
                        <dd id="model-type" class="model-type"></dd>

                        <dt>작성일</dt>
                        <dd id="model-created" class="model-created"></dd>

                        <dt>수정일</dt>
                        <dd id="model-update" class="model-update"></dd>

                        <dt>조회수</dt>
                        <dd id="model-view" class="model-view"></dd>

                        <dt>댓글수</dt>
                        <dd id="model-comment" class="model-comment"></dd>

                        <dt>신고수</dt>
                        <dd id="model-report" class="model-report"></dd>

                        <dt>상태</dt>
                        <dd id="model-status" class="model-status"></dd>

                        <dt>내용</dt>
                        <dd id="model-content" class="model-content"></dd>

                    </dl>

                    <div class="bd-action">

                        <input type="button" class="bd-btn bd-btn-hidden" value="" onclick="boardhidden()" />
                        <input type="button" class="bd-btn bd-btn-delete" value="" onclick="boarddelete()" />

                    </div>

                </div>
            </div>
        </section>
