package com.project.foodsite.controller;

import java.util.*;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.foodsite.util.Recommand;
import com.project.foodsite.util.SearchLog;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class FoodSiteController {
    
    private final Recommand rec;
    private final HttpSession session;
    private final SearchLog log;
    
    @GetMapping( value={"/", "/main_list.do"})
    public String food_main(Model model){
        //등록일자 기준으로 레시피를 불러옴
        model.addAttribute("recommend", rec.recommendList());       //오늘의 레시피를 한개 불러옴
        model.addAttribute("view_recipes", rec.viewCountList());    //조회수를 기준으로 레시피를 불러옴
        log.getSearchLog();
        return "main";
    }

    @PostMapping("/logout.do")
    @ResponseBody
    public Map<String, String> logout(@RequestBody Map<String, String> map) {
        session.removeAttribute("user");
        map.put("result", "success");
        return map;
    }

    @GetMapping("/hidden.do")
    public String hidden(){
        return "fridge/hidden";
    }
    

}
