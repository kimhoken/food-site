<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link rel="stylesheet" href="/css/adminReport.css">

<script>
    function openUserModal(name, nickname, email, profileImg) {
        document.getElementById("modalName").innerText = name;
        document.getElementById("modalNickname").innerText = nickname;
        document.getElementById("modalEmail").innerText = email;

        const img = document.getElementById("modalProfileImg");
        const fileName = profileImg ? profileImg.trim() : "";

        if (fileName !== "" && fileName !== "null" && fileName !== "no_file.png") {
            img.src = "/upload/profile/" + fileName;
        } else {
            img.src = "/images/no_file.png";
        }

        document.getElementById("userModal").style.display = "flex";
    }

    function closeUserModal() {
        document.getElementById("userModal").style.display = "none";
    }

    function openReportDetailModal(reportId) {
    document.getElementById("detailModalTarget").innerText =
        document.getElementById("reportTarget-" + reportId).innerText.trim();

    document.getElementById("detailModalStatus").innerText =
        document.getElementById("reportStatus-" + reportId).innerText.trim();

    document.getElementById("detailModalReason").innerText =
        document.getElementById("reportReason-" + reportId).innerText.trim();

    document.getElementById("detailModalTitle").innerText =
        document.getElementById("reportTitle-" + reportId).innerText.trim();

    document.getElementById("detailModalContent").innerText =
        document.getElementById("reportDetail-" + reportId).innerText.trim();

    document.getElementById("reportDetailModal").style.display = "flex";
    }
    
    function closeReportDetailModal() {
        document.getElementById("reportDetailModal").style.display = "none";
    }
</script>

<c:if test="${empty sessionScope.user or sessionScope.user.role ne 'ADMIN'}">
    <script>
        alert("관리자만 이용 가능한 페이지입니다.");
        location.href = "/main_list.do";
    </script>
</c:if>

<c:if test="${not empty sessionScope.user and sessionScope.user.role eq 'ADMIN'}">

<div class="report-admin-page">

    <div class="report-title-box">
        <h2>신고 관리</h2>
        <p>회원 신고 내역을 확인하고 경고를 부여할 수 있습니다.</p>
    </div>

    <div class="report-table-wrap">
        <table class="report-table">
            <thead>
                <tr>
                    <th>번호</th>
                    <th>신고 대상</th>
                    <th>신고받은 대상</th>
                    <th>신고 제목</th>
                    <th>상태</th>
                    <th>신고일</th>
                    <th>신고자</th>
                    <th>경고여부</th>
                </tr>
            </thead>

            <tbody>
                <c:forEach var="vo" items="${list}">
                    <tr>
                        <td>${vo.report_id}</td>

                        <td>
                            <c:choose>
                                <c:when test="${vo.target_type eq '리뷰'}">후기</c:when>
                                <c:otherwise>${vo.target_type}</c:otherwise>
                            </c:choose>
                        </td>

                        <td class="target-link-td">
                            <c:choose>
                                <c:when test="${vo.target_type eq '커뮤니티'}">
                                    <a class="report-link" href="/view.do?board_id=${vo.board_id}">게시글 보러가기</a>
                                </c:when>

                                <c:when test="${vo.target_type eq '커뮤니티 댓글'}">
                                    <a class="report-link" href="/view.do?board_id=${vo.board_id}#comment-${vo.comment_id}">게시글 댓글 보러가기</a>
                                </c:when>

                                <c:when test="${vo.target_type eq '레시피'}">
                                    <a class="report-link" href="/recipe_detail.do?recipe_id=${vo.recipe_id}">레시피 보러가기</a>
                                </c:when>

                                <c:when test="${vo.target_type eq '레시피 댓글'}">
                                    <a class="report-link" href="/recipe_detail.do?recipe_id=${vo.recipe_id}#comment-${vo.comment_id}">레시피 댓글 보러가기</a>
                                </c:when>

                                <c:when test="${vo.target_type eq '리뷰'}">
                                    <a class="report-link" href="/list.do?btn=review">후기 보러가기</a>
                                </c:when>

                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <button type="button"
                                    class="detail-btn"
                                    onclick="openReportDetailModal('${vo.report_id}')">
                                ${vo.report_title}
                            </button>

                            <span id="reportTarget-${vo.report_id}" style="display:none;">
                                <c:choose>
                                    <c:when test="${vo.target_type eq '리뷰'}">후기</c:when>
                                    <c:otherwise>${vo.target_type}</c:otherwise>
                                </c:choose>
                            </span>

                            <span id="reportStatus-${vo.report_id}" style="display:none;">${vo.status}</span>
                            <span id="reportReason-${vo.report_id}" style="display:none;">${vo.reason}</span>
                            <span id="reportTitle-${vo.report_id}" style="display:none;">${vo.report_title}</span>
                            <span id="reportDetail-${vo.report_id}" style="display:none;">${vo.detail}</span>
                        </td>

                        <td>
                            <span class="status-badge ${vo.status eq '경고처리' ? 'warning-status' : 'wait-status'}">
                                ${vo.status}
                            </span>
                        </td>

                        <td>
                            <fmt:formatDate value="${vo.created_date}" pattern="yyyy-MM-dd HH:mm"/>
                        </td>

                        <td>
                            <button type="button"
                                    class="user-btn"
                                    onclick="openUserModal('${vo.name}', '${vo.nickname}', '${vo.email}', '${vo.profile_img}')">
                                ${vo.nickname}
                            </button>
                        </td>

                        <td class="action-td">
                            <form action="/report/admin/warning.do" method="post" class="warning-form">
                                <input type="hidden" name="report_id" value="${vo.report_id}">
                                <input type="submit"
                                       class="warning-btn"
                                       value="경고부여"
                                       onclick="return confirm('해당 신고 대상 작성자에게 경고 1회를 부여하시겠습니까?');">
                            </form>

                            <form action="/report/admin/delete.do" method="post" class="delete-form">
                                <input type="hidden" name="report_id" value="${vo.report_id}">
                                <input type="submit"
                                       class="cancel-btn"
                                       value="신고삭제"
                                       onclick="return confirm('해당 신고를 삭제하시겠습니까?');">
                            </form>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty list}">
                    <tr>
                        <td colspan="8" class="empty-report">등록된 신고가 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <div class="report-page-box">
            <c:if test="${paging.prev}">
                <a href="/report/admin/list.do?page=${paging.startpage - 1}">◀</a>
            </c:if>

            <c:forEach var="p" begin="${paging.startpage}" end="${paging.endpage}">
                <a href="/report/admin/list.do?page=${p}"
                   class="${paging.page eq p ? 'active' : ''}">
                    ${p}
                </a>
            </c:forEach>

            <c:if test="${paging.next}">
                <a href="/report/admin/list.do?page=${paging.endpage + 1}">▶</a>
            </c:if>
        </div>
    </div>
</div>

</c:if>

<div id="userModal" class="modal-bg">
    <div class="user-modal-box">
        <h3>회원 정보</h3>

        <img id="modalProfileImg"
             src="/images/no_file.png"
             alt="프로필 이미지"
             class="modal-profile-img">

        <p><strong>이름:</strong> <span id="modalName"></span></p>
        <p><strong>닉네임:</strong> <span id="modalNickname"></span></p>
        <p><strong>이메일:</strong> <span id="modalEmail"></span></p>

        <input type="button"
               value="닫기"
               class="modal-close-btn"
               onclick="closeUserModal()">
    </div>
</div>

<div id="reportDetailModal" class="modal-bg">
    <div class="report-detail-modal-box">
        <h3>신고 상세 내용</h3>

        <p class="detail-modal-line">
            <strong class="detail-modal-label">신고 대상:</strong>
            <span class="detail-modal-text" id="detailModalTarget"></span>
        </p>

        <p class="detail-modal-line">
            <strong class="detail-modal-label">상태:</strong>
            <span class="detail-modal-text" id="detailModalStatus"></span>
        </p>

        <p class="detail-modal-line">
            <strong class="detail-modal-label">신고 사유:</strong>
            <span class="detail-modal-text" id="detailModalReason"></span>
        </p>

        <p class="detail-modal-line">
            <strong class="detail-modal-label">신고 제목:</strong>
            <span class="detail-modal-text" id="detailModalTitle"></span>
        </p>

        <div id="detailModalContent" class="detail-content-box"></div>

        <input type="button"
               value="닫기"
               class="modal-close-btn"
               onclick="closeReportDetailModal()">
    </div>
</div>