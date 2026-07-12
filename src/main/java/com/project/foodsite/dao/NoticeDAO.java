package com.project.foodsite.dao;

import java.util.List;

import com.project.foodsite.vo.ImgVO;
import com.project.foodsite.vo.NoticeVO;

public interface NoticeDAO {

    // 검색 조건과 페이징 범위에 해당하는 공지사항 목록 조회
    List<NoticeVO> selectList(
            int start, int pageSize, String search_text);

    // 검색 조건에 해당하는 전체 공지사항 개수 조회
    int notice_count(String search_text);

    // 공지사항 번호로 상세 정보 조회
    NoticeVO noticeView(int notice_id);

    // 공지사항 등록
    int notice_insert(NoticeVO vo);

    // 공지사항 이미지 등록
    int notice_img_insert(ImgVO img);

    // 공지사항 번호로 이미지 조회
    ImgVO notice_img_select(int notice_id);

    // 공지사항 이미지 목록 수정
    int notice_img_update(ImgVO img);

    // 공지사항 이미지 정보 삭제
    int notice_img_delete(int notice_id);

    // 공지사항 삭제
    int notice_delete(int notice_id);

    // 공지사항 제목과 내용 수정
    int notice_update(NoticeVO vo);
}