<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="/css/report.css">

    <%-- 신고 대상 ID가 하나도 없으면 신고 페이지 접근 차단 --%>
    <c:if test="${empty param.board_id and empty param.comment_id and empty param.recipe_id and empty param.review_id}">
        <script>
            alert("신고 대상이 없습니다.");
            location.href = "/main_list.do";
        </script>
    </c:if>
</head>

<body>
<c:choose>

    <%-- 로그인하지 않은 사용자는 신고 기능 이용 불가 --%>
    <c:when test="${empty sessionScope.user}">
        <script>
            alert("로그인 후 이용해주세요.");
            location.href = "/login.do";
        </script>
    </c:when>

    <c:otherwise>

        <div class="report-page">
            <div class="report-wrap">

                <div class="report-title-box">
                    <h2>신고하기</h2>
                    <p>부적절한 게시물이나 댓글을 신고할 수 있습니다.</p>
                </div>

                <%-- 신고 내용을 서버로 전송하는 폼 --%>
                <form action="/report/insert.do"
                        method="post"
                        class="report-form"
                        onsubmit="return submitReport();">

                    <input type="hidden" name="target_type" value="${report.target_type}">

                    <%-- 신고 대상별 식별 번호 전달 --%>
                    <input type="hidden" name="board_id" value="${param.board_id}">
                    <input type="hidden" name="comment_id" value="${param.comment_id}">
                    <input type="hidden" name="recipe_id" value="${param.recipe_id}">
                    <input type="hidden" name="review_id" value="${param.review_id}">

                    <c:if test="${report.target_type eq '커뮤니티' and not empty board}">
                        <div class="report-target-box">
                            <div class="report-target-label">신고 대상 게시글</div>

                            <a href="/view.do?board_id=${board.board_id}" class="report-target-title">
                                ${board.title}
                            </a>
                        </div>
                    </c:if>

                    <c:if test="${report.target_type eq '커뮤니티 댓글'}">
                        <div class="report-target-box">
                            <div class="report-target-label">신고 대상 게시글 댓글</div>

                            <button type="button"
                                    class="report-target-title report-link-btn"
                                    onclick="openCommentModal()">
                                댓글 보러가기
                            </button>
                        </div>
                    </c:if>

                    <c:if test="${report.target_type eq '레시피'}">
                        <div class="report-target-box">
                            <div class="report-target-label">신고 대상 레시피</div>

                            <a href="/recipe_detail.do?recipe_id=${param.recipe_id}" class="report-target-title">
                                ${recipe.report_title}
                            </a>
                        </div>
                    </c:if>

                    <c:if test="${report.target_type eq '레시피 댓글'}">
                        <div class="report-target-box">
                            <div class="report-target-label">신고 대상 레시피 댓글</div>

                            <button type="button"
                                    class="report-target-title report-link-btn"
                                    onclick="openCommentModal()">
                                댓글 보러가기
                            </button>
                        </div>
                    </c:if>

                    <c:if test="${report.target_type eq '리뷰'}">
                        <div class="report-target-box">
                            <div class="report-target-label">신고 대상 후기게시판</div>

                            <a href="/list.do?btn=review" class="report-target-title">
                                ${review.report_title}
                            </a>
                        </div>
                    </c:if>

                    <div class="form-row">
                        <label>신고 사유</label>
                        <select name="reason" required>
                            <option value="">선택하세요</option>
                            <option value="욕설/비방">욕설/비방</option>
                            <option value="광고/도배">광고/도배</option>
                            <option value="음란물">음란물</option>
                            <option value="허위정보">허위정보</option>
                            <option value="기타">기타</option>
                        </select>
                    </div>

                    <div class="form-row">
                        <label>신고 제목</label>
                        <input type="text" name="report_title" maxlength="50" required
                               placeholder="신고 제목을 입력하세요">
                    </div>

                    <div class="form-row">
                        <label>신고 상세 내용</label>
                        <textarea name="detail" rows="8"
                                  placeholder="신고 상세 내용을 입력하세요"></textarea>
                    </div>

                    <div class="report-btn-wrap">
                        <input type="submit" value="신고하기" class="report-submit-btn">
                        <input type="button" value="취소" onclick="history.back()" class="report-cancel-btn">
                    </div>

                </form>
            </div>
        </div>

        <%-- 신고 대상 댓글 내용을 확인하는 모달창 --%>
        <div id="commentModal" class="comment-modal">
            <div class="comment-modal-box">

                <div class="comment-modal-header">
                    <h3>신고 대상 댓글</h3>
                    <button type="button" onclick="closeCommentModal()">×</button>
                </div>

                <div class="comment-modal-meta">
                    댓글 작성자: ${comment.nickname}
                </div>

                <div class="comment-modal-content">${comment.detail}</div>

                <div class="comment-modal-footer">
                    <button type="button" onclick="closeCommentModal()">닫기</button>
                </div>

            </div>
        </div>

        <script>

            function openCommentModal() {
                document.getElementById("commentModal").style.display = "flex";
            }

            function closeCommentModal() {
                document.getElementById("commentModal").style.display = "none";
            }
        </script>

    </c:otherwise>

</c:choose>
</body>
</html>