// 북마크 등록/ 해제
function bookmarkSet( recipe_id ){   

    fetch("/bookmark/set",{
        method:'post',
        headers:{"Content-Type": "application/x-www-form-urlencoded"},
        body: "recipe_id="+recipe_id
    }).then( res => res.json())
    .then( data => {

        console.log(data);

        if (data.result > 0 && data.status == "insert") {   

            alert("북마크 되었습니다.")
            document.querySelector("recipe-bookmark-btn").value="북마크 해제";

        } else if( data.result > 0 && data.status == "delete") {

            alert("북마크 해제 되었습니다");
            document.querySelector("recipe-bookmark-btn").value="북마크";
        } else {

            alert("이스터에그");

        }
    })
}