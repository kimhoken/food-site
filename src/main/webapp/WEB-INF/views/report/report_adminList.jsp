<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link rel="stylesheet" href="/css/adminReport.css">

<script>
   
    function openUserModal(reportId) {
        
        const name =
            document.getElementById("userName-" + reportId);

        const nickname =
            document.getElementById("userNickname-" + reportId);

        const email =
            document.getElementById("userEmail-" + reportId);

        const profileImg =
            document.getElementById("userProfileImg-" + reportId);

        // 이름,닉네임,이메일이 존재하면 출력하고, 없으면 "-" 표시
        document.getElementById("modalName").innerText =
            name && name.innerText.trim() !== ""
                ? name.innerText.trim()
                : "-";

        document.getElementById("modalNickname").innerText =
            nickname && nickname.innerText.trim() !== ""
                ? nickname.innerText.trim()
                : "-";

        document.getElementById("modalEmail").innerText =
            email && email.innerText.trim() !== ""
                ? email.innerText.trim()
                : "-";

        // 회원 정보 모달에 표시할 프로필 이미지 태그
        const modalProfileImg =
            document.getElementById("modalProfileImg");

        const fileName =
            profileImg ? profileImg.innerText.trim() : "";

        // 등록된 프로필 이미지가 있으면 업로드 경로 사용,
        // 없으면 기본 프로필 이미지 사용
        if (
            fileName !== "" &&
            fileName !== "null" &&
            fileName !== "no_file.png"
        ) {
            modalProfileImg.src =
                "/upload/profile/" + fileName;
        } else {
            modalProfileImg.src =
                "/images/no_file.png";
        }

        document.getElementById("userModal").style.display = "flex";
    }

    function closeUserModal() {
        document.getElementById("userModal").style.display = "none";
    }

    // 신고 제목 버튼 클릭 시 신고 상세 내용을 모달에 표시
    function openReportDetailModal(reportId) {

        // 선택한 신고 번호에 해당하는 신고 정보를 가져옴
        const target =
            document.getElementById("reportTarget-" + reportId);

        const status =
            document.getElementById("reportStatus-" + reportId);

        const reason =
            document.getElementById("reportReason-" + reportId);

        const title =
            document.getElementById("reportTitle-" + reportId);

        const detail =
            document.getElementById("reportDetail-" + reportId);

        document.getElementById("detailModalTarget").innerText =
            target && target.innerText.trim() !== ""
                ? target.innerText.trim()
                : "-";

        document.getElementById("detailModalStatus").innerText =
            status && status.innerText.trim() !== ""
                ? status.innerText.trim()
                : "-";

        document.getElementById("detailModalReason").innerText =
            reason && reason.innerText.trim() !== ""
                ? reason.innerText.trim()
                : "-";

        document.getElementById("detailModalTitle").innerText =
            title && title.innerText.trim() !== ""
                ? title.innerText.trim()
                : "-";

        document.getElementById("detailModalContent").innerText =
            detail && detail.innerText.trim() !== ""
                ? detail.innerText.trim()
                : "등록된 신고 상세 내용이 없습니다.";

        document.getElementById(
            "reportDetailModal"
        ).style.display = "flex";
    }

    function closeReportDetailModal() {
        document.getElementById(
            "reportDetailModal"
        ).style.display = "none";
    }

    // 신고된 댓글 또는 후기의 원문을 모달에 표시
    function openTargetContentModal(reportId) {
        const type =
            document.getElementById("targetType-" + reportId);

        const writer =
            document.getElementById("targetWriter-" + reportId);

        const content =
            document.getElementById("targetContent-" + reportId);

        const date =
            document.getElementById("targetDate-" + reportId);

        document.getElementById("targetModalType").innerText =
            type && type.innerText.trim() !== ""
                ? type.innerText.trim()
                : "-";

        document.getElementById("targetModalWriter").innerText =
            writer && writer.innerText.trim() !== ""
                ? writer.innerText.trim()
                : "작성자 정보 없음";

        document.getElementById("targetModalContent").innerText =
            content && content.innerText.trim() !== ""
                ? content.innerText.trim()
                : "삭제되었거나 존재하지 않는 내용입니다.";

        document.getElementById("targetModalDate").innerText =
            date && date.innerText.trim() !== ""
                ? date.innerText.trim()
                : "-";

        document.getElementById(
            "targetContentModal"
        ).style.display = "flex";
    }

    function closeTargetContentModal() {
        document.getElementById(
            "targetContentModal"
        ).style.display = "none";
    }


    window.addEventListener("click", function(event) {
        const userModal =
            document.getElementById("userModal");

        const reportDetailModal =
            document.getElementById("reportDetailModal");

        const targetContentModal =
            document.getElementById("targetContentModal");

        if (event.target === userModal) {
            closeUserModal();
        }

        if (event.target === reportDetailModal) {
            closeReportDetailModal();
        }

        if (event.target === targetContentModal) {
            closeTargetContentModal();
        }
    });
</script>

<!-- 비로그인 상태이거나 ADMIN 권한이 아닌 경우
    관리자 신고 관리 페이지 접근 차단 -->
<c:if test="${empty sessionScope.user or sessionScope.user.role ne 'ADMIN'}">
    <script>
        alert("관리자만 이용 가능한 페이지입니다.");
        location.href = "/main_list.do";
    </script>
</c:if>

<!-- 관리자 로그인 상태일 때만 신고 관리 화면 출력 -->
<c:if test="${not empty sessionScope.user and sessionScope.user.role eq 'ADMIN'}">

    <div class="report-admin-page">

        <div class="report-title-box">
            <h2>신고 관리</h2>

            <p>
                회원 신고 내역을 확인하고 경고를 부여할 수 있습니다.
            </p>
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

                            <td>
                                ${vo.report_id}
                            </td>


                            <td>
                                <c:choose>

                                    <c:when test="${vo.target_type eq '리뷰'}">
                                        후기
                                    </c:when>

                                    <c:otherwise>
                                        ${vo.target_type}
                                    </c:otherwise>

                                </c:choose>
                            </td>


                            <td class="target-link-td">

                                <c:choose>

                                    <c:when test="${vo.target_type eq '커뮤니티'}">

                                        <a class="report-link"
                                           href="/view.do?board_id=${vo.board_id}">
                                            게시글 보러가기
                                        </a>

                                    </c:when>

                                    <c:when test="${vo.target_type eq '커뮤니티 댓글'}">

                                        <button type="button"
                                                class="report-link target-modal-btn"
                                                onclick="openTargetContentModal('${vo.report_id}')">
                                            댓글 보기
                                        </button>

                                    </c:when>


                                    <c:when test="${vo.target_type eq '레시피'}">

                                        <a class="report-link"
                                           href="/recipe_detail.do?recipe_id=${vo.recipe_id}">
                                            레시피 보러가기
                                        </a>

                                    </c:when>

                                    <c:when test="${vo.target_type eq '레시피 댓글'}">

                                        <button type="button"
                                                class="report-link target-modal-btn"
                                                onclick="openTargetContentModal('${vo.report_id}')">
                                            댓글 보기
                                        </button>

                                    </c:when>

                                    <c:when test="${vo.target_type eq '리뷰'}">

                                        <button type="button"
                                                class="report-link target-modal-btn"
                                                onclick="openTargetContentModal('${vo.report_id}')">
                                            후기 보기
                                        </button>

                                    </c:when>


                                    <c:otherwise>
                                        -
                                    </c:otherwise>

                                </c:choose>


                                <c:if test="${vo.target_type eq '커뮤니티 댓글'
                                              or vo.target_type eq '레시피 댓글'
                                              or vo.target_type eq '리뷰'}">

                                    <span id="targetType-${vo.report_id}"
                                          style="display:none;">

                                        <c:choose>

                                            <c:when test="${vo.target_type eq '리뷰'}">
                                                후기
                                            </c:when>

                                            <c:otherwise>
                                                댓글
                                            </c:otherwise>

                                        </c:choose>

                                    </span>

                                    <span id="targetWriter-${vo.report_id}"
                                          style="display:none;">
                                        ${vo.target_writer}
                                    </span>

                                    <span id="targetContent-${vo.report_id}"
                                          style="display:none;">
                                        ${vo.target_content}
                                    </span>


                                    <!-- 신고 대상 원문의 작성일
                                        LocalDateTime의 T 문자를 공백으로 변경 -->
                                    <span id="targetDate-${vo.report_id}"
                                          style="display:none;">
                                        ${fn:replace(vo.target_created_date, 'T', ' ')}
                                    </span>

                                </c:if>

                            </td>

                            <td>

                                <button type="button"
                                        class="detail-btn"
                                        onclick="openReportDetailModal('${vo.report_id}')">
                                    ${vo.report_title}
                                </button>

                                <span id="reportTarget-${vo.report_id}"
                                      style="display:none;">

                                    <c:choose>

                                        <c:when test="${vo.target_type eq '리뷰'}">
                                            후기
                                        </c:when>

                                        <c:otherwise>
                                            ${vo.target_type}
                                        </c:otherwise>

                                    </c:choose>

                                </span>


                                <span id="reportStatus-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.status}
                                </span>


                                <span id="reportReason-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.reason}
                                </span>


                                <span id="reportTitle-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.report_title}
                                </span>


                                <span id="reportDetail-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.detail}
                                </span>

                            </td>

                            <td>

                                <span class="status-badge
                                    ${vo.status eq '경고처리'
                                        ? 'warning-status'
                                        : 'wait-status'}">

                                    ${vo.status}

                                </span>

                            </td>

                            <td>
                                ${fn:replace(vo.created_date, 'T', ' ')}
                            </td>

                            <td>

                                <button type="button"
                                        class="user-btn"
                                        onclick="openUserModal('${vo.report_id}')">
                                    ${vo.nickname}
                                </button>

                                <span id="userName-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.name}
                                </span>


                                <span id="userNickname-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.nickname}
                                </span>


                                <span id="userEmail-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.email}
                                </span>


                                <span id="userProfileImg-${vo.report_id}"
                                      style="display:none;">
                                    ${vo.profile_img}
                                </span>

                            </td>

                            <td class="action-td">

                                 <!-- 신고 대상 작성자에게 경고 1회 부여 -->
                                <form action="/report/admin/warning.do"
                                      method="post"
                                      class="warning-form">

                                    <input type="hidden"
                                           name="report_id"
                                           value="${vo.report_id}">


                                    <input type="submit"
                                           class="warning-btn"
                                           value="경고부여"
                                           onclick="return confirm('해당 신고 대상 작성자에게 경고 1회를 부여하시겠습니까?');">

                                </form>


                                <form action="/report/admin/delete.do"
                                      method="post"
                                      class="delete-form">

                                    <input type="hidden"
                                           name="report_id"
                                           value="${vo.report_id}">


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
                            <td colspan="8"
                                class="empty-report">
                                등록된 신고가 없습니다.
                            </td>
                        </tr>

                    </c:if>

                </tbody>

            </table>

            <!-- 신고 목록 페이징 -->
            <div class="report-page-box">

                <c:if test="${paging.prev}">

                    <a href="/report/admin/list.do?page=${paging.startpage - 1}">
                        ◀
                    </a>

                </c:if>


                <c:forEach var="p"
                           begin="${paging.startpage}"
                           end="${paging.endpage}">

                    <a href="/report/admin/list.do?page=${p}"
                       class="${paging.page eq p ? 'active' : ''}">
                        ${p}
                    </a>

                </c:forEach>


                <c:if test="${paging.next}">

                    <a href="/report/admin/list.do?page=${paging.endpage + 1}">
                        ▶
                    </a>

                </c:if>

            </div>

        </div>

    </div>

</c:if>

<div id="userModal"
     class="modal-bg">

    <div class="user-modal-box">

        <h3>회원 정보</h3>


        <img id="modalProfileImg"
             src="/images/no_file.png"
             alt="프로필 이미지"
             class="modal-profile-img">


        <p>
            <strong>이름:</strong>
            <span id="modalName"></span>
        </p>


        <p>
            <strong>닉네임:</strong>
            <span id="modalNickname"></span>
        </p>


        <p>
            <strong>이메일:</strong>
            <span id="modalEmail"></span>
        </p>


        <input type="button"
               value="닫기"
               class="modal-close-btn"
               onclick="closeUserModal()">

    </div>

</div>


<div id="reportDetailModal"
     class="modal-bg">

    <div class="report-detail-modal-box">

        <h3>신고 상세 내용</h3>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                신고 대상:
            </strong>

            <span class="detail-modal-text"
                  id="detailModalTarget"></span>

        </p>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                상태:
            </strong>

            <span class="detail-modal-text"
                  id="detailModalStatus"></span>

        </p>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                신고 사유:
            </strong>

            <span class="detail-modal-text"
                  id="detailModalReason"></span>

        </p>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                신고 제목:
            </strong>

            <span class="detail-modal-text"
                  id="detailModalTitle"></span>

        </p>


        <div id="detailModalContent"
             class="detail-content-box">
        </div>


        <input type="button"
               value="닫기"
               class="modal-close-btn"
               onclick="closeReportDetailModal()">

    </div>

</div>


<div id="targetContentModal"
     class="modal-bg">

    <div class="report-detail-modal-box">

        <h3>신고 대상 원문</h3>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                구분:
            </strong>

            <span class="detail-modal-text"
                  id="targetModalType"></span>

        </p>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                작성자:
            </strong>

            <span class="detail-modal-text"
                  id="targetModalWriter"></span>

        </p>


        <p class="detail-modal-line">

            <strong class="detail-modal-label">
                작성일:
            </strong>

            <span class="detail-modal-text"
                  id="targetModalDate"></span>

        </p>


        <div class="target-content-label">
            작성된 원문
        </div>


        <div id="targetModalContent"
             class="detail-content-box">
        </div>


        <input type="button"
               value="닫기"
               class="modal-close-btn"
               onclick="closeTargetContentModal()">

    </div>

</div>
