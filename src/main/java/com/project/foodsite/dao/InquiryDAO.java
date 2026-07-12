package com.project.foodsite.dao;

import java.util.List;

import com.project.foodsite.vo.InquiryVO;

public interface InquiryDAO {

    // 문의 등록
    int insertInquiry(InquiryVO vo);

    // 비회원 문의 확인 코드 저장
    int updateInquiryCode(InquiryVO vo);

    // 문의 확인 코드로 비회원 문의 조회
    InquiryVO guestInquiryCode(String inquiry_code);

    // 관리자 문의 전체 목록 조회
    List<InquiryVO> adminInquiryList();

    // 관리자 문의 상세 조회
    InquiryVO adminInquiryDetail(int inquiry_id);

    // 관리자 문의 답변 등록
    int answerInquiry(InquiryVO vo);

    // 특정 회원의 문의 목록 조회
    List<InquiryVO> myInquiryList(int member_id);

    // 미답변 문의 개수 조회
    int inquiryCount();
}