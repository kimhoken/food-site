<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>

    <link rel="stylesheet" href="/css/main.css">
    <link rel="stylesheet" href="/css/notice_update.css">

    <script>
        // 새로 선택한 이미지 파일들을 따로 저장
        let selectedFiles = []; 

        function updateSend(f) {
            let title = f.title.value.trim();
            let content = f.content.value.trim();

            if (title === "") {
                alert("공지사항 제목을 입력하세요.");
                f.title.focus();
                return;
            }

            if (content === "") {
                alert("공지사항 내용을 입력하세요.");
                f.content.focus();
                return;
            }

            updateFileInput(); 
            f.submit();
        }

        // 기존에 등록된 이미지 삭제 처리
        function removeOldImage(btn, fileName) {
            const form = document.getElementById("noticeUpdateForm");

            const input = document.createElement("input");
            input.type = "hidden";
            input.name = "delete_image";
            input.value = fileName;

            form.appendChild(input);

            // 화면에서 해당 이미지 미리보기 제거
            btn.closest(".img-item").remove();
        }

        // 새 이미지 선택 시 기존 선택 목록에 추가
        function changeImages(input) {
            selectedFiles = selectedFiles.concat(Array.from(input.files));
            input.value = "";
            renderPreview();
            updateFileInput();
        }

        // 새 이미지 미리보기 출력
        function renderPreview() {
            const previewList = document.getElementById("preview-list");
            previewList.innerHTML = "";

            selectedFiles.forEach(function(file, index) {
                const item = document.createElement("div");
                item.className = "img-item";

                const btn = document.createElement("button");
                btn.type = "button";
                btn.className = "img-remove-btn";
                btn.innerText = "×";

                // 선택한 새 이미지 목록에서 해당 파일 삭제
                btn.onclick = function() {
                    removeNewFile(index);
                };

                const img = document.createElement("img");

                // 브라우저에서 선택한 파일의 임시 미리보기 주소 생성
                img.src = URL.createObjectURL(file);
                img.alt = "추가 이미지";

                item.appendChild(btn);
                item.appendChild(img);
                previewList.appendChild(item);
            });
        }

        // 새로 선택한 이미지 X 삭제
        function removeNewFile(index) {
            selectedFiles.splice(index, 1);
            renderPreview();
            updateFileInput();
        }

        // 실제 input 파일 목록 갱신
        function updateFileInput() {
            const imageInput = document.getElementById("images");
            const dataTransfer = new DataTransfer();

            selectedFiles.forEach(function(file) {
                dataTransfer.items.add(file);
            });

            imageInput.files = dataTransfer.files;
        }
    </script>
</head>

<body>
    <jsp:include page="/WEB-INF/views/common/navibar.jsp" />

    <main class="notice-update-page">

        <section class="update-head">
            <span>NOTICE EDIT</span>
            <h2>공지사항 수정</h2>
        </section>

        <section class="update-card">

            <form id="noticeUpdateForm" action="notice_update.do" method="post" enctype="multipart/form-data">

                <input type="hidden" name="notice_id" value="${notice.notice_id}">

                <div class="form-group">
                    <label>제목</label>
                    <input type="text" name="title" value="${notice.title}">
                </div>

                <div class="form-group">
                    <label>내용</label>
                    <textarea name="content">${notice.content}</textarea>
                </div>

                <div class="form-group">
                    <label>이미지</label>

                    <%-- 기존 등록 이미지가 있을 때만 출력 --%>
                    <c:if test="${not empty img and not empty img.image_list}">
                        <div class="current-img-box">

                            <%-- 쉼표로 저장된 이미지 파일명을 나누어 반복 출력 --%>
                            <c:forEach var="fileName" items="${fn:split(img.image_list, ',')}">
                                <div class="img-item">

                                    <%-- 기존 이미지 삭제 버튼 --%>
                                    <button type="button"
                                            class="img-remove-btn"
                                            onclick="removeOldImage(this, '${fileName}')">×</button>

                                    <img src="/upload/${fileName}" alt="공지 이미지">
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>

                    <div id="preview-list"></div>

                    <div class="file-box">
                        <%-- 여러 이미지 파일 선택 가능 --%>
                        <input type="file" name="images"  id="images"  multiple accept="image/*" onchange="changeImages(this)"> 
                    </div>
                </div>

                <div class="btn-area">
                    <button type="button" class="submit-btn" onclick="updateSend(this.form)">수정완료</button>
                    <button type="button" class="back-btn" onclick="history.back()">뒤로가기</button>
                </div>

            </form>
        </section>

    </main>
</body>
</html>