<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="/css/inquiry.css">

        <script>
            function send(f) {
                const type = f.type.value.trim();
                const title = f.title.value.trim();
                const content = f.content.value.trim();

                if (type === "") {
                    alert("문의 유형을 선택하세요.");
                    f.type.focus();
                    return;
                }

                if (title === "") {
                    alert("제목을 입력하세요.");
                    f.title.focus();
                    return;
                }

                if (title.length > 100) {
                    alert("제목은 100자 이하로 입력하세요.");
                    f.title.focus();
                    return;
                }

                if (content === "") {
                    alert("내용을 입력하세요.");
                    f.content.focus();
                    return;
                }

                // 비회원 문의인 경우 이름, 이메일, 비밀번호 추가 검증
                if (f.guest_name) {
                    const guestName = f.guest_name.value.trim();
                    const guestEmail = f.guest_email.value.trim();
                    const guestPassword = f.guest_password.value.trim();

                    const nameRegex = /^[가-힣a-zA-Z]{2,20}$/;
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d).{8,20}$/;

                    if (guestName === "") {
                        alert("이름을 입력하세요.");
                        f.guest_name.focus();
                        return;
                    }

                    if (!nameRegex.test(guestName)) {
                        alert("이름은 한글 또는 영문 2~20자로 입력하세요.");
                        f.guest_name.focus();
                        return;
                    }

                    if (guestEmail === "") {
                        alert("이메일을 입력하세요.");
                        f.guest_email.focus();
                        return;
                    }

                    if (!emailRegex.test(guestEmail)) {
                        alert("이메일 형식이 올바르지 않습니다.");
                        f.guest_email.focus();
                        return;
                    }

                    if (guestPassword === "") {
                        alert("비밀번호를 입력하세요.");
                        f.guest_password.focus();
                        return;
                    }

                    if (!passwordRegex.test(guestPassword)) {
                        alert("비밀번호는 영문과 숫자를 포함해 8~20자로 입력하세요.");
                        f.guest_password.focus();
                        return;
                    }
                }

                // 개인정보 수집 동의 여부 확인
                const agree = document.getElementById("agree");

                if (!agree.checked) {
                    alert("개인정보 수집 및 이용에 동의해주세요.");
                    agree.focus();
                    return;
                }

                // if (f.guest_name) {
                //     alert("문의되었습니다.\n비회원은 작성일로부터 14일 동안 문의 내역을 확인할 수 있습니다.");
                // } else {
                //     alert("문의되었습니다.\n회원은 작성일로부터 90일 동안 문의 내역을 확인할 수 있습니다.");
                // }

                //테스트용 
                if (f.guest_name) {
                    alert("문의되었습니다.\n비회원은 작성일로부터 70초 동안 문의 내역을 확인할 수 있습니다.");
                } else {
                    alert("문의되었습니다.\n회원은 작성일로부터 100초 동안 문의 내역을 확인할 수 있습니다.");
                }

                f.submit();
            }

            // 개인정보 수집 동의 모달 열기
            function openAgreeModal() {
                const agree = document.getElementById("agree");
                const modalAgree = document.getElementById("modalAgree");

                modalAgree.checked = agree.checked;
                document.getElementById("agreeModal").style.display = "flex";
            }

            function closeAgreeModal() {
                document.getElementById("agreeModal").style.display = "none";
            }

            // 모달에서 동의 시 메인 체크박스와 동기화
            function agreeAndCloseModal() {
                document.getElementById("agree").checked = true;
                document.getElementById("modalAgree").checked = true;
                document.getElementById("agreeModal").style.display = "none";
            }

            let files = [];

            window.onload = function () {
                const imageInput = document.getElementById("image");
                const previewList = document.getElementById("preview-list");

                imageInput.addEventListener("change", function () {
                    files = files.concat(Array.from(this.files));
                    this.value = "";
                    renderPreview();
                });

                // 선택한 이미지 미리보기 생성
                window.renderPreview = function () {
                    previewList.innerHTML = "";

                    const dataTransfer = new DataTransfer();

                    files.forEach(function (file, index) {
                        dataTransfer.items.add(file);

                        const item = document.createElement("div");
                        item.className = "preview-item";

                        item.innerHTML =
                            '<img src="' + URL.createObjectURL(file) + '">' +
                            '<button type="button" onclick="removeFile(' + index + ')">×</button>';

                        previewList.appendChild(item);
                    });

                    imageInput.files = dataTransfer.files;
                };

                // 선택한 이미지 삭제 후 목록 갱신
                window.removeFile = function (index) {
                    files.splice(index, 1);
                    renderPreview();
                };
            };
        </script>
    </head>

    <body>

        <div class="inquiry-page">

            <form action="/inquiry" method="post" enctype="multipart/form-data" class="inquiry-form">

                <div class="inquiry-title-box">
                    <span class="inquiry-label">CONTACT</span>
                    <h2>1:1 문의하기</h2>
                    <p>
                        궁금한 점이 있으시면 언제든지 문의해 주세요.<br>
                        빠르고 친절하게 답변드리겠습니다.
                    </p>
                </div>

                <table class="inquiry-table">
                    <tr>
                        <th>유형</th>
                        <td>
                            <select name="type">
                                <option value="">선택</option>
                                <option value="계정">계정</option>
                                <option value="레시피 문의">레시피 문의</option>
                                <option value="서비스 이용 문의">서비스 이용 문의</option>
                                <option value="기타">기타</option>
                            </select>
                        </td>
                    </tr>

                    <!-- 로그인 여부에 따라 회원 또는 비회원 입력 폼 표시 -->
                    <c:if test="${not empty sessionScope.user}">
                        <tr>
                            <th>이름</th>
                            <td>
                                <input type="text" value="${sessionScope.user.nickname}" readonly>
                                <input type="hidden" name="member_id" value="${sessionScope.user.member_id}">
                            </td>
                        </tr>
                    </c:if>

                    <c:if test="${empty sessionScope.user}">
                        <tr>
                            <th>이름</th>
                            <td>
                                <input type="text" name="guest_name" placeholder="이름을 입력하세요">
                            </td>
                        </tr>

                        <tr>
                            <th>이메일</th>
                            <td>
                                <input type="email" name="guest_email" placeholder="example@email.com">
                            </td>
                        </tr>

                        <tr>
                            <th>비밀번호</th>
                            <td>
                                <input type="password" name="guest_password" placeholder="영문과 숫자 포함 8~20자">
                            </td>
                        </tr>
                    </c:if>

                    <tr>
                        <th>제목</th>
                        <td>
                            <input type="text" name="title" maxlength="200" placeholder="제목을 입력하세요">
                        </td>
                    </tr>

                    <tr>
                        <th>내용</th>
                        <td>
                            <textarea name="content" rows="8" placeholder="문의 내용을 입력하세요"></textarea>
                        </td>
                    </tr>

                    <tr>
                        <th>파일 첨부</th>
                        <td>
                            <input type="file" name="image" id="image" accept="image/*" multiple>
                            <div id="preview-list"></div>
                        </td>
                    </tr>

                    <tr>
                        <th>개인정보 수집</th>
                        <td>
                            <div class="agree-row">
                                <label class="agree-radio">
                                    <input type="checkbox" name="privacy_agree" value="Y" id="agree">
                                    <span></span>
                                    개인정보 수집 및 이용에 동의합니다. (필수)
                                </label>

                                <button type="button" class="agree-detail-btn" onclick="openAgreeModal()">
                                    자세히 &gt;
                                </button>
                            </div>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="2" class="btn-area">
                            <input type="button" class="submit-btn" value="문의하기" onclick="send(this.form)">
                            <input type="button" class="cancel-btn" value="취소" onclick="history.back()">
                        </td>
                    </tr>
                </table>
            </form>
        </div>

        <!-- 개인정보 수집 및 이용 안내 모달 -->
        <div id="agreeModal" class="agree-modal">
            <div class="agree-modal-content">
                <button type="button" class="close-btn" onclick="closeAgreeModal()">✕</button>

                <div class="privacy-box">
                    <h3>개인정보 수집 및 이용 안내</h3>

                    <p>회사는 문의 접수 및 고객 상담 서비스 제공을 위하여 아래와 같이 개인정보를 수집·이용합니다.</p>

                    <div class="privacy-section">
                        <h4>1. 수집하는 개인정보 항목</h4>
                        <ul>
                            <li>이름</li>
                            <li>이메일 주소</li>
                            <li>문의 유형</li>
                            <li>문의 제목 및 내용</li>
                        </ul>
                    </div>

                    <div class="privacy-section">
                        <h4>2. 개인정보 수집 및 이용 목적</h4>
                        <p>수집된 개인정보는 다음의 목적을 위해 이용됩니다.</p>
                        <ul>
                            <li>문의사항 접수 및 본인 확인</li>
                            <li>문의 내용 확인 및 답변 제공</li>
                            <li>서비스 이용 관련 고객 지원</li>
                            <li>불만 처리 및 분쟁 해결</li>
                            <li>서비스 품질 향상을 위한 통계 분석</li>
                        </ul>
                    </div>

                    <div class="privacy-section">
                        <h4>3. 개인정보 보유 및 이용 기간</h4>
                        <p>
                            문의 접수 및 처리 완료 후 관련 법령에 따라 필요한 경우를 제외하고,
                            수집 목적이 달성된 날로부터 최대 3년간 보관 후 안전하게 파기합니다.
                        </p>
                    </div>

                    <div class="privacy-section">
                        <h4>4. 개인정보의 제3자 제공</h4>
                        <p>
                            회사는 이용자의 동의 없이 개인정보를 외부에 제공하지 않으며,
                            법령에 특별한 규정이 있는 경우를 제외하고 제3자에게 제공하지 않습니다.
                        </p>
                    </div>

                    <div class="privacy-section">
                        <h4>5. 동의 거부 권리 및 불이익</h4>
                        <p>
                            이용자는 개인정보 수집 및 이용에 대한 동의를 거부할 권리가 있습니다.
                            다만, 필수 정보 수집에 동의하지 않을 경우 문의 접수 및 답변 서비스 이용이 제한될 수 있습니다.
                        </p>
                    </div>

                    <p class="privacy-confirm">
                        본인은 위 개인정보 수집 및 이용 안내를 충분히 확인하였으며, 이에 동의합니다.
                    </p>
                </div>

                <div class="agree-modal-footer">
                    <label class="modal-agree-check">
                        <input type="checkbox" id="modalAgree" onclick="agreeAndCloseModal()">
                        개인정보 수집 및 이용에 동의합니다. <strong>(필수)</strong>
                    </label>
                </div>
            </div>
        </div>

    </body>
</html>
