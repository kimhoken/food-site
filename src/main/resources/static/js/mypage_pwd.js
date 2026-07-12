
// 비밀번호 유효성 상태 변수
let pwd_valid = false;
let pwd_check_valid = false;

//비밀번호 재설정 페이지 확인 함수
function pwdUserCheck() {

    let pwd = document.getElementById("pwdUserCheck").value;

    fetch("/userpwdcheck.do", {
        method: 'post',
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: 'currpwd=' + encodeURIComponent(pwd)
    }).then(res => res.text())
        .then(data => {
            alert(data);
            if (data === "ok") {
                document.querySelector("#pwd_box").style.display = "none";
                document.querySelector("#pwd_reset_box").style.display = "block";
            } else {
                alert("현재 비밀번호가 일치 하지 않습니다.");
            }
        })

}

//비밀번호 재설정
function password_reset(f) {
    //비밀번호 규칙에 맞지 않을 경우
    if (!pwd_valid) {
        alert("비밀번호 규칙에 맞게 입력해주세요(영어, 숫자, 특수문자(! @ # $ % ^ & *) 포함 10자 이상)");
        return;
    }

    //비밀번호가 일치하지 않을 경우
    if(!pwd_check_valid) {
        alert("비밀번호가 일치 하지 않습니다");
        return ;
    }

    let pwd = f.pwd.value;
    let pwd_check = f.pwd_check.value;

    fetch("/resetpwdpage.do", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: 'password=' + encodeURIComponent(pwd)
    })
    .then(res => res.text())
    .then(data => {
        if (data.trim() == "success") {
            alert("비밀번호가 재설정되었습니다.");
            location.href = "/mypage.do?menu=account";
        } else {
            alert("비밀번호 재설정에 실패했습니다. 다시 시도해주세요.");
        }
    })
}

//비밀번호 유효성 검사
function pwdchange() {

    let pwd = document.getElementById("pwd").value;
    let pwd_check = document.getElementById("pwd_check").value;
    let pwd_msg = document.getElementById("pwd_msg");
    let pwd_check_msg = document.getElementById("pwd_check_msg");

    const regex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*]).{10,}$/;

    if(!regex.test(pwd)){
        pwd_msg.innerHTML = '영문 특수문자(! @ # $ % ^ & *) 포함 10자 이상 포함되야 합니다.';
        return;
    }

    fetch("/pwd_check.do",
        {
            method: 'post',
            headers: { 'Content-Type': "application/x-www-form-urlencoded" },
            body: 'pwd=' + encodeURIComponent(pwd) +
                '&pwd_check=' + encodeURIComponent(pwd_check)
        })
        .then(res => res.json())
        .then(data => {

            if (data.pwd_msg == "no") {

                pwd_msg.innerHTML = '영문 특수문자(! @ # $ % ^ & *) 포함 10자 이상 포함되야 합니다.';

            } else if (data.pwd_msg == "yes") {

                pwd_msg.innerHTML = '사용가능합니다.';
                document.getElementById("pwd_check").focus();
                pwd_valid = true;
                
            } else {
                pwd_msg.innerHTML = "오류 발생";
            }

            if (data.pwd_check_msg == "no") {

                pwd_check_msg.innerHTML = '일치하지 않습니다.';

            } else if (data.pwd_check_msg == "yes") {

                pwd_check_msg.innerHTML = '일치합니다.';
                pwd_check_valid = true;

            } else {
                pwd_check_msg.innerHTML = "오류 발생";
            }


        })

}