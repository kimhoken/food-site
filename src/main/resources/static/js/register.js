let id_vailed = false;
let pwd_vailed = false;
let email_vailed = false;
let nickname_vailed = false;


window.addEventListener( "load", function () {

    let nicknames = document.getElementById("nickname");
    nicknames.value = nickname;

    let emails = document.getElementById("email");
    let names = document.getElementById("name");
    let social_button = document.getElementById("soical_button");
    let social_row = document.getElementById("soical_row");

    
    //소셜 회원가입 설정
    if (provider != null && provider !== "") {
        emails.readOnly = true;
        emails.value = email;
        email_vailed = true;
        id_vailed = true;
        pwd_vailed = true;
        names.value = name;
        social_button.style.display = "none";
        social_row.style.display = "none";
    }


    let unvisual = document.getElementById("unvisual");
    unvisual.style.display = "none";
}); 


let email_authnumer;

function status() {
    id_vailed = false;
}

//아이디 중복 검사
function id_check() {

    let id = document.getElementById("id");
    let id_msg = document.getElementById("id_msg");

    if (id.value == "") {
        id_msg.innerHTML = "아이디 입력하세요";
        id.focus();
        return;
    }

    fetch("/check_id.do", {
        method: 'post',
        headers: { 'Content-Type': "application/x-www-form-urlencoded" },
        body: 'login_id=' + encodeURIComponent(id.value)
    })
        .then(res => res.json())
        .then(data => {

            if (data.id_msg == "yes") {

                id_msg.innerHTML = data.id + "는 사용가능합니다";
                id_vailed = true;

            } else if (data.id_msg == 'no') {

                id_msg.innerHTML = data.id + "는 이미 사용중인 아이디 입니다.";
                return;

            } else {
                id_msg.innerHTML = "오류가 발생했습니다";
            }

        })
}

//비밀번호 확인 함수
function pwd_checks() {
    let pwd = document.getElementById("pwd").value;
    let pwd_check = document.getElementById("pwd_check").value;
    let pwd_msg = document.getElementById("pwd_msg");
    let pwd_check_msg = document.getElementById("pwd_check_msg");

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

                pwd_msg.innerHTML = '영문 특수문자 포함 10자 이상 포함되야 합니다.';

            } else if (data.pwd_msg == "yes") {

                pwd_msg.innerHTML = '사용가능합니다.';
                document.getElementById("pwd_check").focus();

            } else {
                pwd_msg.innerHTML = "오류 발생";
            }

            if (data.pwd_check_msg == "no") {

                pwd_check_msg.innerHTML = '일치하지 않습니다.';

            } else if (data.pwd_check_msg == "yes") {

                pwd_check_msg.innerHTML = '일치합니다.';
                pwd_vailed = true;

            } else {
                pwd_check_msg.innerHTML = "오류 발생";
            }


        })

}

//회원 가입 함수
function send(f) {
    console.log(provider);

    if (!id_vailed) {
        alert("아이디 중복 검사가 필요합니다.");
        f.login_id.focus();
        return;
    }

    if (!pwd_vailed) {
        alert("비밀번호 입력하세요.");
        f.password.focus();
        return;
    }

    let name = f.name.value;
    let email = f.email.value;

    if (name == "") {
        alert("이름을 입력하세요!!");
        f.name.focus();
        return;
    }


    if (email == "") {
        alert("이메일을 입력하세요!!");
        f.email.focus();
        return;
    }

    let formData = new FormData(f);

    fetch('/register.do', {
        method: 'post',
        body: formData
    }).then(res => res.json())
        .then(data => {
            if (data.res == 1) {
                alert("회원 가입 성공!!");
                location.href = '/login.do';
            } else {
                alert("회원 가입 실패!!");
            }
        })

}

//이메일 인증번호 전송 함수
function mailcheck(f) {
    let email = f.email.value;
    
    if(email === ""){
        alert("이메일 입력하세요!!");
        f.email.focus();
        return;
    }

    fetch("/mail_check.do", {
        method: 'post',
        headers: { 'Content-Type': "application/x-www-form-urlencoded" },
        body: 'email=' + encodeURI(email)
    })
        .then(res => res.json())
        .then(data => {
            alert("인증번호가 발송되었습니다.");

            email_authnumer = data.authNumber;
        })
}

// 이메일 인증번호 검사
function change_input() {

    let authnumber = document.getElementById("authnumber").value;
    let email_msg = document.getElementById("email_msg");

    if (authnumber == email_authnumer) {
        email_msg.innerHTML = "인증되었습니다."
        email_vailed = true;
    } else if (authnumber != email_authnumer) {
        email_msg.innerHTML = "인증번호가 틀렸습니다."
    } else {
        email_msg.innerHTML = "오류발생"
    }

}
//닉네임 중복 처리 함수(사용자가 임의의 닉네임 입력시 )
function nick() {
    let nickname = document.getElementById("nickname").value;
    let nick_msg = document.getElementById("nick_msg");

    fetch("/check_nickname.do",

        {
            method: 'post',
            headers: { 'Content-Type': "application/x-www-form-urlencoded" },
            body: 'nickname=' + nickname

        }).then(res => res.json())
        .then(data => {

            if (data.nickname_msg == "yes") {

                nick_msg.innerHTML = "이미 있는 닉네임입니다.";
                nickname_vailed = false;

            } else if (data.nickname_msg == "no") {

                nick_msg.innerHTML = data.nickname + "은 사용가능합니다.";
                nickname_vailed = true;

            }
        })

}

// 비밀번호 입력시 보이게 안보이게 설정
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
