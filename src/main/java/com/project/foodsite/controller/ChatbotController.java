package com.project.foodsite.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.foodsite.dao.ChatbotDAO;
import com.project.foodsite.vo.ChatbotVO;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ChatbotController {

    private final ChatbotDAO chatbotDao;
    
    // 챗봇 메인 화면 이동
    @GetMapping("/chatbot")
    public String chatbotmain(){
        return "chatbot/chatbot_main";
    }
    
    // 최상위 챗봇 메뉴 목록을 JSON 형태로 반환
    @GetMapping("/chatbot/parent")
    @ResponseBody
    public List<ChatbotVO> parent() {
        return chatbotDao.selectParent();
    }

    // 선택한 상위 메뉴의 하위 질문 목록을 JSON 형태로 반환
    @GetMapping("/chatbot/sub")
    @ResponseBody
    public List<ChatbotVO> sub(int id) {
        return chatbotDao.selectSub(id);
    }   
}
