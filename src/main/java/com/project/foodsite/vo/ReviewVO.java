package com.project.foodsite.vo;

import java.util.List;

import org.apache.ibatis.type.Alias;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("review")
public class ReviewVO {
    private int review_id;          // 후기 번호
    private int recipe_id;          // 레시피 번호
    private int member_id;          // 회원 번호
    private int img_id;            // 이미지 번호
    private String title;           // 후기 제목
    private String content;         // 후기 내용
    private String thumbnail;           // 후기 대표 이미지
    private double rating;          // 평점 (0.0 ~ 5.0)
    private int view_count;         // 조회수
    private String status;          // 상태 (N: 정상, Y: 삭제)
    private String created_at;   // 작성일
    private String updated_at;   // 수정일
    private String recipe_thumbnail; 

    private List<MultipartFile> photo; // 이미지 저장 
    private MultipartFile singlephoto;

    //  member 테이블에서 가져올 회원 닉네임 추가
    private String nickname;
}
