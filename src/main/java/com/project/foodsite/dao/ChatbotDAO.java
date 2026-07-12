package com.project.foodsite.dao;

import java.util.List;

import com.project.foodsite.vo.ChatbotVO;

public interface ChatbotDAO {
    
    // 사용 중인 최상위 챗봇 메뉴 목록 조회
    List<ChatbotVO> selectParent();
    // 선택한 상위 메뉴 번호를 기준으로 하위 질문 목록 조회
    List<ChatbotVO> selectSub(int parentId);
}
