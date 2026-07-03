package com.project.foodsite.dto;

import java.util.List;

import org.apache.ibatis.type.Alias;

import com.project.foodsite.vo.CookOrderVO;
import com.project.foodsite.vo.IngredientVO;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Alias("RecipeDetailDTO")
public class RecipeDetailDTO {
    //레시피 테이블의 정보들
    private int recipeId;
    private Integer foodId;
    private String recipeTitle;
    private String thumbnail;
    private String cookingTime;
    private String difficulty;
    private int viewCount;
    private int likeCount;
    private String status;
    private String createdDate;
    private String updatedDate;

    //조리 순서테이블에서 넘어올 정보들
    List<CookOrderVO> cookOrderList;
    
    //재료테이블에서 넘어올 정보들
    List<IngredientVO> ingredientList;

    //멤버테이블의 닉네임
    private String nickName;

    //작성자의 memberId
    private Long memberId;

    
}
