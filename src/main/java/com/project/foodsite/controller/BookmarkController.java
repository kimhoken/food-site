package com.project.foodsite.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.foodsite.dao.BookmarkDAO;
import com.project.foodsite.vo.BookmarkVO;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class BookmarkController {
    
    private final BookmarkDAO bookmarkDAO;
    private final HttpSession httpSession;

    // 북마크 등록/ 해제
    @PostMapping("/bookmark/set")
    @ResponseBody
    public Map<String,Object> bookmark_set(int recipe_id){        
        
        MemberVO user = (MemberVO)httpSession.getAttribute("user");
                
        BookmarkVO bookmark = bookmarkDAO.selectbookmark(recipe_id, user.getMember_id());

        Map<String,Object> map = new HashMap<>();

        if(bookmark == null){

            BookmarkVO newBookmark = new BookmarkVO();

            newBookmark.setRecipe_id(recipe_id);
            newBookmark.setMember_id(user.getMember_id());

            int res = bookmarkDAO.insertbookmark(newBookmark);

            map.put("result", res);
            map.put("status", "insert");

            return map;
        } else {

            int res = bookmarkDAO.deletebookmark(bookmark.getBookmark_id());

            map.put("result", res);
            map.put("status", "delete");

            return map;
        }

    }

}
