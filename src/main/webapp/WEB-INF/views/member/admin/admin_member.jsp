<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<head>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_member.css" />

    <script>
        function member_view(member_id) {
            fetch("/admin/member/info", {
                method: "post",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "member_id=" + member_id
            }).then(res => res.json())
                .then(dto => {
                    console.log(dto);

                    filemember(dto);

                    document.querySelector(".ma-btn-stop").onclick =
                        () => memberStop(dto.member_id);

                    document.querySelector(".ma-btn-report").onclick =
                        () => memberReport(dto.member_id);

                    document.querySelector(".ma-detail-panel").classList.add("active");
                });
        }

        function filemember(dto) {
            setImg("model-img", "/upload/profile/" + dto.profile_img);
            setText("name", dto.name);
            setText("intro", dto.memberintro ?? dto.member_intro);
            setText("nickname", dto.nickname);
            setText("id", dto.login_id ?? dto.provider ?? "-");
            setText("email", dto.email);
            setText("report", dto.report_count);
            setText("date", dto.created_date);
            setText("recipe", dto.recipe_count);
            setText("comment", dto.comment_count);
            setText("bookmark", dto.bookmark_count);
            setText("like", dto.like_count);
            setText("up-report", "신고 내역 구현 예정");

            if (dto.status === "ACTIVE") {
                document.querySelector(".model-status").textContent = "정상";
                document.querySelector(".ma-btn-stop").value = "회원 정지";
            } else if (dto.status === "SUSPEND") {
                document.querySelector(".model-status").textContent = "정지";
                document.querySelector(".ma-btn-stop").value = "정지 해제";
            } else {
                document.querySelector(".model-status").textContent = dto.status ?? "-";
                document.querySelector(".ma-btn-stop").value = "회원 정지";
            }

            if (dto.role === "ADMIN") {
                document.querySelector(".ma-btn-rank").value = "일반 회원 변경";
            } else if (dto.role === "USER") {
                document.querySelector(".ma-btn-rank").value = "관리자 변경";
            } else {
                document.querySelector(".ma-btn-rank").value = "등급 변경";
            }
        }

        function searchmember() {
            document.querySelector('form[action="/admin/member"]').submit();
        }

        function entersearch(e) {
            if (e.key === "Enter") {
                searchmember();
            }
        }

        function memberStop(id) {
            if (!confirm("회원 상태를 변경하시겠습니까?")) {
                return;
            }

            fetch("/admin/member/stop", {
                method: "post",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "member_id=" + id
            }).then(res => res.json())
                .then(data => {
                    if (data.status === "SUSPEND" && data.result > 0) {
                        alert(data.nickname + " 회원을 정지했습니다.");
                    } else if (data.status === "ACTIVE" && data.result > 0) {
                        alert(data.nickname + " 회원의 정지를 해제했습니다.");
                    } else {
                        alert("처리할 수 없습니다.");
                    }
                });
        }

        function memberReport(id) {
            alert("신고 내역 기능은 구현 예정입니다. 회원 번호: " + id);
        }

        function closeMemberDetail() {
            document.querySelector(".ma-detail-panel").classList.remove("active");
        }
    </script>
</head>

<section class="ma-container admin-member-page">
    <div class="ma-wrap">
        <div class="ma-header">
            <h3 class="ma-title">회원 관리</h3>
            <small class="ma-subtitle">전체 회원 목록과 상세 정보를 관리할 수 있습니다.</small>
        </div>

        <div class="ma-content">
            <div class="ma-list-panel">
                <form action="/admin/member" method="get">
                    <div class="ma-filter">
                        <input type="text" class="ma-search" name="keyword" placeholder="아이디, 닉네임, 이메일 검색"
                            onkeydown="entersearch(event)" />

                        <select class="ma-status" name="status" onchange="searchmember()">
                            <option value="">상태</option>
                            <option value="ACTIVE" ${adminmember.status eq 'ACTIVE' ? 'selected' : '' }>정상</option>
                            <option value="SUSPEND" ${adminmember.status eq 'SUSPEND' ? 'selected' : '' }>정지</option>
                            <option value="WITHDRAW" ${adminmember.status eq 'WITHDRAW' ? 'selected' : '' }>탈퇴</option>
                        </select>

                        <select class="ma-role" name="role" onchange="searchmember()">
                            <option value="">등급</option>
                            <option value="ADMIN" ${adminmember.role eq 'ADMIN' ? 'selected' : '' }>관리자</option>
                            <option value="USER" ${adminmember.role eq 'USER' ? 'selected' : '' }>회원</option>
                        </select>
                    </div>

                    <table class="ma-table">
                        <tr>
                            <th>프로필</th>
                            <th>닉네임</th>
                            <th>아이디</th>
                            <th>이메일</th>
                            <th>등급</th>
                            <th>신고</th>
                            <th>상태</th>
                            <th>가입일</th>
                        </tr>

                        <tbody>
                            <c:forEach var="member" items="${list}">
                                <tr class="ma-row" onclick="member_view('${member.member_id}')">
                                    <td>
                                        <img class="ma-profile-img" src="/upload/profile/${member.profile_img}" />
                                    </td>
                                    <td>${member.nickname}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty member.login_id}">
                                                ${member.login_id}
                                            </c:when>
                                            <c:otherwise>
                                                ${member.provider}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${member.email}</td>
                                    <td>${member.role}</td>
                                    <td>
                                        <span class="ma-report-count">${member.report_count}</span>
                                    </td>
                                    <td>
                                        <c:if test="${member.status eq 'ACTIVE'}">
                                            <span class="ma-badge ma-active">정상</span>
                                        </c:if>
                                        <c:if test="${member.status eq 'SUSPEND'}">
                                            <span class="ma-badge ma-suspend">정지</span>
                                        </c:if>
                                        <c:if test="${member.status eq 'WITHDRAW'}">
                                            <span class="ma-badge ma-withdraw">탈퇴</span>
                                        </c:if>
                                    </td>
                                    <td>${member.created_date}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <footer class="ma-footer">
                        <div class="ma-total">총 회원: ${totalcount}명</div>
                        <div class="ma-paging">
                            <c:set var="pageUrl"
                                value="/admin/member?keyword=${adminmember.keyword}&status=${adminmember.status}&role=${adminmember.role}"
                                scope="request" />
                            <jsp:include page="/WEB-INF/views/common/paging.jsp" />
                        </div>
                    </footer>
                </form>
            </div>
        </div>

        <div class="ma-detail-panel">
            <div class="ma-detail-header">
                <h3>프로필</h3>
                <button type="button" class="ra-close" onclick="closeMemberDetail()">x</button>
            </div>

            <div class="ma-profile-box">
                <img id="model-img" class="ma-detail-img" src="" />
                <div class="ma-profile-info">
                    <strong id="model-name" class="model-name">이름</strong>
                    <small id="model-intro" class="model-intro">자기소개</small>
                </div>
            </div>

            <dl class="ma-detail-list">
                <dt>닉네임</dt>
                <dd id="model-nickname" class="model-nickname"></dd>

                <dt>아이디</dt>
                <dd id="model-id" class="model-id"></dd>

                <dt>이메일</dt>
                <dd id="model-email" class="model-email"></dd>

                <dt>신고</dt>
                <dd id="model-report" class="model-report"></dd>

                <dt>상태</dt>
                <dd id="model-status" class="model-status"></dd>

                <dt>가입일</dt>
                <dd id="model-date" class="model-date"></dd>

                <dt>작성 레시피</dt>
                <dd id="model-recipe" class="model-recipe"></dd>

                <dt>작성 댓글</dt>
                <dd id="model-comment" class="model-comment"></dd>

                <dt>북마크</dt>
                <dd id="model-bookmark" class="model-bookmark"></dd>

                <dt>좋아요</dt>
                <dd id="model-like" class="model-like"></dd>

                <dt>신고 내역</dt>
                <dd id="model-up-report" class="model-up-report"></dd>
            </dl>

            <div class="ma-action">
                <input type="button" class="ma-btn ma-btn-stop" value="" onclick="" />
                <input type="button" class="ma-btn ma-btn-report" value="신고 내역" onclick="" />
                <input type="button" class="ma-btn ma-btn-rank" value="" onclick="" />
            </div>
        </div>
    </div>
</section>
