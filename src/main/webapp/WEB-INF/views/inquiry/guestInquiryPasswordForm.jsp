<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="/css/guestInquiryPasswordForm.css">

        <script>
            function checkPassword(f) {
                const password = f.guest_password.value.trim();

                if (password === "") {
                    alert("비밀번호를 입력하세요.");
                    f.guest_password.focus();
                    return;
                }

                f.submit();
            }
        </script>
    </head>

    <body>

        <!-- 비회원 문의 확인 기간이 만료된 경우 메인으로 이동 -->
        <c:if test="${expired eq 'yes'}">
            <script>
                alert("비회원 문의 확인 기간이 만료되었습니다."); 
                location.href="/main_list.do"; 
            </script>
        </c:if>

        <div class="guest-inquiry-page">

            <div class="guest-inquiry-box">

                <div class="guest-title-box">
                    <span class="guest-label">INQUIRY</span>
                    <h2>문의 답변 확인</h2>
                    <p>
                        문의 작성 시 설정한 비밀번호를 입력하면<br>
                        관리자 답변을 확인할 수 있습니다.
                    </p>
                </div>

                <!-- 비밀번호 불일치 등의 오류 메시지 출력 -->
                <c:if test="${not empty msg}">
                    <div class="error-msg">${msg}</div>
                </c:if>

                <form action="/guest/inquiry/check"
                      method="post"
                      class="password-form">

                    <!-- 조회할 비회원 문의의 고유 코드 전달 -->
                    <input type="hidden"
                           name="inquiry_code"
                           value="${inquiry_code}">

                    <label>비밀번호</label>

                    <input type="password"
                           name="guest_password"
                           placeholder="문의 작성 시 입력한 비밀번호">

                    <div class="password-guide">
                        비밀번호가 일치해야 문의 내용과 답변을 확인할 수 있습니다.
                    </div>

                    <div class="password-btn-area">
                        <input type="button"
                               value="답변 확인"
                               class="check-btn"
                               onclick="checkPassword(this.form)">

                        <input type="button"
                               value="메인으로"
                               class="home-btn"
                               onclick="location.href='/main_list.do'">
                    </div>

                </form>

            </div>

        </div>

    </body>
</html>