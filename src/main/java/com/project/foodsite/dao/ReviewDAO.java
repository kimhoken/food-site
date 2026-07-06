package com.project.foodsite.dao;

import java.util.*;

import com.project.foodsite.dto.AdminReviewDTO;
import com.project.foodsite.dto.ReviewDetailDTO;
import com.project.foodsite.vo.ReviewVO;


public interface ReviewDAO {
    List<ReviewVO> reviewLatest();                  // 최신순
    List<ReviewVO> reviewPopular(String period);    // 조회수순(전체, 주간, 월간)
                   

    // 관리자 총 레시피 후기 갯수 조회
    int ReviewCount(AdminReviewDTO Review);

    // 관리자 레시피 검색 (페이징 포함)
    List<AdminReviewDTO> ReviewSearch(AdminReviewDTO Review);

    AdminReviewDTO adminReviewDetail(int review_id);

    // 별점순(평점순)
    List<ReviewVO> reviewRating();

    int reviewStatus(AdminReviewDTO Review);

    int reviewInsert(ReviewVO review);

    ReviewDetailDTO selectreview(int review_id);

    int deletereview(int review_id);

    int reviewUpdate( ReviewVO review );

    int reviewCount(Map<String, Object> map);
    
    List<ReviewVO> reviewPage(Map<String, Object> map);

}
