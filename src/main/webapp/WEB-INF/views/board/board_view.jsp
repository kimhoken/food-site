<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.user and sessionScope.user.member_id == board.member_id}"></c:if>
<jsp:include page="/WEB-INF/views/common/navibar.jsp">
    <jsp:param name="currentMenu" value="community" />
</jsp:include>

<!DOCTYPE html>
<html>

<head>

    <link rel="stylesheet" href="/css/main.css">
    <link rel="stylesheet" href="/css/board_view.css">

    <script>
        const del = (commentId) => {
            if (confirm("삭제하시겠습니까?")) {
                fetch("/api/recomment/delete", {
                    method: "delete",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        commentId: commentId
                    })
                })
                .then(res => res.json())
                .then(data => {
                    if (data.result == "success") {
                        alert("삭제되었습니다");
                        location.reload();
                    } else {
                        alert("실패했습니다.");
                    }
                });
            }
        }

        const register = (f) => {
            let content = f.content.value;
            let member_id = f.member_id.value;
            let board_id = f.board_id.value;

            if (!content.trim()) {
                alert("내용은 공백을 제외하고 1자 이상 입력해주세요");
                return;
            }

            if (content.length > 150) {
                alert("댓글은 150자 이내로 작성해주세요.");
                f.content.focus();
                return;
            }

            fetch("/api/recomment/insert", {
                method: "post",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    content: content,
                    recipeId: null,
                    boardId: board_id,
                    memberId: member_id,
                    rating: null
                })
            })
            .then(res => res.json())
            .then(data => {
                if (data.result == "success") {
                    alert("등록되었습니다.");
                    location.reload();
                } else {
                    alert("실패하였습니다...");
                }
            })
            .catch(err => {
                console.log("에러발생 " + err);
            });
        }

        const modi = (commentId) => {
            let btn = document.getElementById("send_btn" + commentId);
            let content = document.getElementById("modi_content" + commentId);

            btn.type = "button";
            content.readOnly = false;
            content.style = "border:1px solid #333;";
            content.focus();
        }

        const modiFin = (commentId) => {
            let content = document.getElementById("modi_content" + commentId);

            if (content.value.length > 150) {
                alert("댓글은 150자 이내로 작성해주세요.");
                content.focus();
                return;
            }

            content.readOnly = true;

            fetch("/api/recomment/update", {
                method: "put",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    commentId: commentId,
                    content: content.value
                })
            })
            .then(res => res.json())
            .then(data => {
                if (data.result == "success") {
                    alert("수정되었습니다.");
                    location.reload();
                } else {
                    alert("실패하였습니다...");
                }
            });
        }

        // 댓글 ⋮ 버튼 클릭 시 드롭다운 열고 닫기
        const toggleCommentMenu = (commentId) => {
            const menu = document.getElementById("commentMenu" + commentId);

            if (menu.style.display === "none" || menu.style.display === "") {
                menu.style.display = "block";
            } else {
                menu.style.display = "none";
            }
        }

        document.addEventListener("click", function(e) {
            if (!e.target.closest(".comment-menu-wrap")) {
                document.querySelectorAll(".comment-dropdown").forEach(menu => {
                    menu.style.display = "none";
                });
            }
        });
    </script>
</head> 

<body>

    <div class="board-view">

        <h2>${board.title}</h2>

        <hr>

        <div class="board-info">
            <span>작성자 : ${board.nickname}</span>
            <span>조회수 : ${board.view_count}</span>
            <span>작성일 : ${board.created_date}</span>
        </div>

        <hr>

        <div class="content">${board.content}</div>

        <br>

        <div class="btn-area">
            <div class="btn-center">
                <input type="button" value="목록으로" onclick="location.href='/list.do'">
            </div>

            <div class="btn-right">
                <c:if test="${sessionScope.user.member_id == board.member_id}">
                    <input type="button" value="수정" onclick="location.href='/update_form.do?board_id=${board.board_id}'">
                    <input type="button" value="삭제"
                           onclick="if(confirm('삭제하시겠습니까?')){location.href='/delete.do?board_id=${board.board_id}'}">
                </c:if>

               <a class="board-report-btn"
                href="/report/form.do?target_type=게시판&board_id=${board.board_id}">
                    신고
                </a>
            </div>
        </div>

        <%-- 댓글 영역 시작 --%>
        <c:if test="${not empty commentList}">
            <div class="comment-main-title">댓글</div>

            <div class="read-comment-div">
                <c:forEach var="vo" items="${commentList}">
                    <table id="comment-${vo.comment_id}">
                        <tr>
                            <td>${vo.nickname}</td>

                            <td>

                                <textarea class="comment-content"
                                          id="modi_content${vo.comment_id}"
                                          maxlength="150"
                                          readonly>${vo.content}</textarea>
                            </td>

                            <td>
                                <input type="hidden" id="send_btn${vo.comment_id}" value="등록" onClick="modiFin('${vo.comment_id}')">

                                <div class="comment-menu-wrap" style="position:relative; display:inline-block;">
                                    <button type="button" class="comment-toggle-btn" onclick="toggleCommentMenu('${vo.comment_id}')">⋮</button>

                                    <div id="commentMenu${vo.comment_id}"
                                        class="comment-dropdown"
                                        style="display:none; position:absolute; right:0; background:white; border:1px solid #ccc;">
                                        <ul>
                                            <li>
                                                <a href="/report/form.do?target_type=댓글&board_id=${board.board_id}&comment_id=${vo.comment_id}">
                                                    신고
                                                </a>
                                            </li>

                                            <li>
                                                <c:if test="${vo.member_id eq sessionScope.user.member_id}">
                                                    <a href="javascript:void(0);" onclick="modi('${vo.comment_id}')">수정</a>
                                                </c:if>
                                            </li>

                                            <li>
                                                <c:if test="${vo.member_id eq sessionScope.user.member_id || sessionScope.user.role eq 'ADMIN'}">
                                                    <a href="javascript:void(0);" onclick="del('${vo.comment_id}')">삭제</a>
                                                </c:if>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </c:forEach>
            </div>
            <c:if test="${commentPaging.totalcount > commentPaging.size}">
                <div class="comment-paging">

                    <c:if test="${commentPaging.prev}">
                        <a href="/view.do?board_id=${board.board_id}&commentPage=${commentPaging.startpage - 1}#comment-section">
                            ◀
                        </a>
                    </c:if>

                    <c:forEach var="i" begin="${commentPaging.startpage}" end="${commentPaging.endpage}">
                        <a href="/view.do?board_id=${board.board_id}&commentPage=${i}#comment-section"
                           class="${commentPaging.page == i ? 'active' : ''}">
                            ${i}
                        </a>
                    </c:forEach>

                    <c:if test="${commentPaging.next}">
                        <a href="/view.do?board_id=${board.board_id}&commentPage=${commentPaging.endpage + 1}#comment-section">
                            ▶
                        </a>
                    </c:if>
                </div>
            </c:if>
        </c:if>

        <c:if test="${empty commentList}">
            <div class="read-comment-div">
                <h2>댓글을 작성해 첫 댓글의 주인공이 되어보세요!</h2>
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.user}">
            <form>
                <div class="comment-insert-div">
                    <table>
                        <tr>
                            <td>
                                댓글 달기
                            </td>

                            <td>
                                <input type="hidden" name="member_id" value="${sessionScope.user.member_id}">
                                <input type="hidden" name="board_id" value="${board.board_id}">
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <textarea name="content"
                                          id="comment-content"
                                          maxlength="150"
                                          placeholder="비방, 욕설 등의 댓글은 무통보 삭제될 수 있습니다."></textarea>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <input type="button" value="등록" class="comment-register" onClick="register(this.form)">
                            </td>
                        </tr>
                    </table>
                </div>
            </form>
        </c:if>
        <%-- 댓글 영역 끝 --%>

    </div>

    
    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>

</html>