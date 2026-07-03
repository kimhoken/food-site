package com.project.foodsite.dto;

import java.util.List;

import org.apache.ibatis.type.Alias;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // getter, setter
@AllArgsConstructor
@NoArgsConstructor
@Alias("RecipeDTO")
public class RecipeDTO {    
    // 제목
    private String title;

    // 레시피 글 등록 대표이미지
    private MultipartFile mainImg;

    //썸네일
    private String thumbnail;

    //조리시간
    private String cooking_time;

    // 재료
    private List<String> ingredientName;
    private List<String> amount;
    private List<String> unit;

    // 조리순서 이미지
    private List<MultipartFile> stepImg;

    // 조리순서 내용
    private List<String> step;

    // 회원번호
    private Long memberId;

    private Integer foodId;

    // 레시피 저장
    private Long recipeId;
}
