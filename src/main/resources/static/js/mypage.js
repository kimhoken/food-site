//const applicationServerKey = "BDbjVtJHaSNMMaypEcx2MeXmHvfoWISYWzTCj6Ycc7SoaucH53CzsDGAen6O4ENI9eZMmnilVr9r0F-q3OSbsiM";

window.onload = function(){
    btn_change("recipe");

}

const logout = () => {
    if (confirm("로그아웃 하시겠습니까?")) {
        fetch("/logout.do", {
            method: "post",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                id: "${user.member_id}"
            })
        })
            .then(res => res.json())
            .then(data => {
                if (data.result == "success") {
                    alert("로그아웃 되었습니다.")
                    location.href = "/main_list.do";
                }
            })
    }
}

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

let pwd_valid = false;
let pwd_check_valid = false;

//비밀번호 재설정
function send(f) {
    //비밀번호 규칙에 맞지 않을 경우
    if (!pwd_valid) {
        alert("비밀번호 규칙에 맞게 입력해주세요(영어, 숫자, 특수문자(! @ # $ % ^ & *) 포함 10자 이상)");
        return;
    }

    //비밀번호가 일치하지 않을 경우
    if(!pwd_check_valid){
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
            location.href = "/mypage?menu=account";
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

function agree() {
    let agree_box = document.getElementById("agree_box");
    let deletebtn = document.querySelector(".delete-btn");
    agree_box.checked = !agree_box.checked;
    
    deletebtn.disabled = !agree_box.checked;

}

let delete_pwd_valid = false;
let delete_text_valid = false;

function setDeleteButtonState(f) {
    let agree_box = document.getElementById("agree_box");
    let deletebtn = document.querySelector(".delete-btn");

    if (!deletebtn || !agree_box) {
        return;
    }

    let has_pwd = f && f.password;
    let delete_valid = has_pwd ? delete_pwd_valid : delete_text_valid;

    deletebtn.disabled = !(agree_box.checked && delete_valid);
}

function deletecheck(input) {
    input = input || (typeof event != "undefined" ? event.target : null) || document.activeElement;

    // if (!input || !input.form) {
    //     return;
    // }

    let f = input.form;
    let pwd_msg = document.getElementById("delete_pwd_msg");
    let text_msg = document.getElementById("delete_text_msg");

    if (input.name == "password") {
        fetch("/userpwdcheck.do", {
            method: "post",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "currpwd=" + encodeURIComponent(input.value)
        }).then(res => res.text())
            .then(data => {
                delete_pwd_valid = data == "ok";

                if (pwd_msg) {
                    pwd_msg.innerHTML = delete_pwd_valid ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.";
                }

                setDeleteButtonState(f);
            })

        return;
    }

    if (input.name == "str") {
        delete_text_valid = input.value == "오늘 뭐먹지?를 탈퇴합니다.";

        if (text_msg) {
            text_msg.innerHTML = delete_text_valid ? "문구가 일치합니다." : "문구가 일치하지 않습니다.";
        }

        setDeleteButtonState(f);
    }
}



document.addEventListener("change", function(e) {
    if (e.target && e.target.id == "agree_box") {
        setDeleteButtonState(e.target.form);
    }
})

function disableuser(f) {

    let agree_box = document.getElementById("agree_box");

    if (!agree_box.checked) {
        alert("동의 해주세요");
        return;
    }

    if (f.password && !delete_pwd_valid) {
        alert("비밀번호를 확인해주세요.");
        return;
    }

    if (f.str && !delete_text_valid) {
        alert("탈퇴 문구를 확인해주세요.");
        return;
    }

    let formdata = new FormData(f);

    fetch("/secessionUser.do", {
        method: 'post',
        body: formdata
    }).then(res => res.text())
        .then(data => {
            if (data == "yes") {
                alert("계정 탈퇴 완료");
                location.href = "main_list.do";
            } else {
                alert("실패");
            }
        })
}

function btn_change(type) {
    const boxes = ["recipe", "comment", "bookmark"];
    let see_btn = document.getElementById("see-btn");
    
    boxes.forEach( name => {
        const box = document.getElementById(name+"box");
        if(box){
            box.style.display = name == type ? "block" : "none";
        }
    });

    document.querySelectorAll(".home-tab-btn").forEach(tab => {
        tab.classList.remove("active");
    });

    const tabs = document.querySelectorAll(".home-tab-btn");
    const activeTab = tabs[boxes.indexOf(type)];

    if( activeTab ) {
        activeTab.classList.add("active");
    }

    if (see_btn) {
        see_btn.onclick = () => location.href= "/mypage.do?menu=" +type;
    }
    

}



