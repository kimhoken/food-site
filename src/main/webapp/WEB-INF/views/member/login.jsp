<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>오늘 뭐 먹지? - 로그인</title>
    <link rel="stylesheet" href="/css/login.css" />
    <link rel="stylesheet" href="/css/modal.css" />

    <script>
        function send(f) {
            let login_id = f.login_id.value;
            let password = f.password.value;

            if (login_id == "") {
                alert("아이디를 입력하세요.");
                return;
            }

            if (password == "") {
                alert("비밀번호를 입력하세요.");
                return;
            }

            let formdata = new FormData(f);
            fetch("/login.do", { method: "post", body: formdata })
                .then(res => res.json())
                .then(data => {
                    if (data.res == "no_id") {
                        alert("아이디가 없거나 틀렸습니다.");
                    } else if (data.res == "no_pwd") {
                        alert("비밀번호가 틀렸습니다.");
                    } else if (data.res == "login") {
                        alert("환영합니다 " + data.nick + "님");
                        location.href = "/main_list.do";
                    } else if (data.res == "suspend") {
                        alert("정지된 계정입니다.\n정지 해제일: " + data.day);
                    } else {
                        alert("알 수 없는 오류");
                    }
                })
        }

        function viewpwd() {
            let pwd = document.getElementById("pwd");
            let visual = document.getElementById("visual");
            let unvisual = document.getElementById("unvisual");

            if (pwd.type === "password") {
                pwd.type = "text";
                visual.style.display = "none";
                unvisual.style.display = "block";
            } else {
                pwd.type = "password";
                visual.style.display = "block";
                unvisual.style.display = "none";
            }
        }

        document.addEventListener("DOMContentLoaded", () => {
            document.querySelectorAll("#login_id, #pwd").forEach(input => {
                input.addEventListener("keydown", function (event) {
                    if (event.key === "Enter") {
                        send(this.form);
                    }
                })
            });
        })
    </script>
</head>

<body>
    <c:if test="${param.error eq 'SUSPEND'}">
        <script>
            alert('정지된 계정입니다. \n정지 해제 날짜는 ${param.day}입니다.');
        </script>
    </c:if>
    <c:if test="${param.error eq 'WITHDRAW'}">
        <script>
            alert("탈퇴한 계정입니다. \n다른 계정으로 로그인해주세요.");
        </script>
    </c:if>

    <main class="login-page">
        <section class="login-left">
            <div class="login-copy">
                <div class="login-copy-icon">
                    <img src="/images/cooking-pot.png" alt="" />
                </div>
                <p class="login-copy-kicker">맛있는 하루의 시작,</p>
                <h1>오늘 뭐 먹지?</h1>
                <p class="login-copy-desc">
                    다양한 레시피를 발견하고<br>
                    나만의 요리를 만들어보세요.
                </p>
                <div class="login-copy-divider"><span></span></div>
            </div>
        </section>

        <section class="login-card">
            <form>
                <div class="login-table">
                    <div class="login-title-box">
                        <h1 class="login-title">로그인</h1>
                        <div class="title-divider"><span></span></div>
                    </div>

                    <div class="form-group">
                        <label for="login_id">아이디</label>
                        <div class="input-wrap">
                            <img src="/images/user.png" alt="" />
                            <input id="login_id" name="login_id" placeholder="아이디를 입력하세요" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="pwd">비밀번호</label>
                        <div class="input-wrap pwd-wrap">
                            <img src="/images/padlock.png" alt="" />
                            <input type="password" name="password" id="pwd" placeholder="비밀번호를 입력하세요" />

                            <button type="button" id="visual" class="toggle" onclick="viewpwd()">
                                <img src="/images/visibility.png" alt="비밀번호 보기" />
                            </button>

                            <button type="button" id="unvisual" class="toggle" onclick="viewpwd()">
                                <img src="/images/unvisibility.png" alt="비밀번호 숨기기" />
                            </button>
                        </div>
                    </div>

                    <div class="idpwd-area">
                        <button class="sub-btn" type="button" onclick="openModal('id',this)">아이디 찾기</button>
                        <span>|</span>
                        <input class="sub-btn" type="button" value="비밀번호 찾기" onclick="openModal('pwd',this)" />
                    </div>

                    <input class="login-btn" type="button" value="로그인" onclick="send(this.form)" />

                    <div class="line-area">
                        <div class="line"></div>
                        <span>또는</span>
                        <div class="line"></div>
                    </div>

                    <div class="social-area">
                        <button type="button" class="social-btn" onclick="location.href='/oauth2/authorization/naver'">
                            <img src="/images/naver.png" alt="" />
                            <span>네이버로 로그인</span>
                        </button>

                        <button type="button" class="social-btn" onclick="location.href='/oauth2/authorization/kakao'">
                            <img src="/images/kakao.png" alt="" />
                            <span>카카오로 로그인</span>
                        </button>

                        <button type="button" class="social-btn" onclick="location.href='/oauth2/authorization/google'">
                            <img src="/images/google.png" alt="" />
                            <span>구글로 로그인</span>
                        </button>
                    </div>

                    <div class="sub-btn-area">
                        <span>계정이 없으신가요?</span>
                        <input class="regi-btn" type="button" value="회원가입" onclick="location.href='/register_form.do'" />
                    </div>
                </div>
            </form>
        </section>
    </main>

    <%@ include file="/WEB-INF/views/member/findmodal.jsp"%>
</body>
</html>
