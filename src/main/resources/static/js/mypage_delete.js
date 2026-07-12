
// 회원 탈퇴 입력 검증 상태
let delete_pwd_valid = false;
let delete_text_valid = false;

// 동의 문구 클릭시 체크박스 토글후 탈퇴 버튼 갱신
function agree() {
    let agree_box = document.getElementById("agree_box");
    let deletebtn = document.querySelector(".delete-btn");
    agree_box.checked = !agree_box.checked;
    
    deletebtn.disabled = !agree_box.checked;

}


// 회원 탈퇴 버튼 활성화
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

// 회원 탈퇴 활성화 기능 
function deletecheck(input) {
    input = input || (typeof event != "undefined" ? event.target : null) || document.activeElement;
  
    let f = input.form;
    let pwd_msg = document.getElementById("delete_pwd_msg");
    let text_msg = document.getElementById("delete_text_msg");

    // 일반 회원 탈퇴시 비밀번호 입력
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

    // 소셜 로그인 회원 탈퇴시 문구 입력
    if (input.name == "str") {
        delete_text_valid = input.value == "오늘 뭐먹지?를 탈퇴합니다.";

        if (text_msg) {
            text_msg.innerHTML = delete_text_valid ? "문구가 일치합니다." : "문구가 일치하지 않습니다.";
        }

        setDeleteButtonState(f);
    }
}

// 동의 체크박스 변경시 탈퇴 버튼 최신화
document.addEventListener("change", function(e) {
    if (e.target && e.target.id == "agree_box") {
        setDeleteButtonState(e.target.form);
    }
})

// 회원 탈퇴 함수
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