package com.project.foodsite.dao;

import java.util.List;
import java.util.Map;

import com.project.foodsite.dto.AdminRecipeDTO;
import com.project.foodsite.dto.RecipeDTO;
import com.project.foodsite.dto.RecipeDetailDTO;
import com.project.foodsite.dto.RecipeSearchDTO;
import com.project.foodsite.vo.RecipeVO;

public interface RecipeDAO {
    int size();

    RecipeVO selectOne(int num);

    List<RecipeVO> selectAll();

    List<RecipeVO> selectAny(String fridgeList);

    // 레시피 목록 조회(카테고리, 조리시간, 정렬 조건 적용)
    List<RecipeVO> selectRecipeList(RecipeSearchDTO searchDTO);

    // 전체 레시피 개수 조회 (페이징 처리용)
    int selectRecipeCount(RecipeSearchDTO searchDTO);

    List<RecipeVO> selectViewCount();

    // 대분류별 소분류 음식 목록 조회
    List<Map<String, Object>> selectFoodListByCategory(String categoryName);

    List<RecipeVO> search(String search);

    // 회원 레시피 개수 조회
    int countUserRecipe(int member_id);

    // 회원의 전체 레시피 리스트 조회
    List<RecipeVO> getUserRecipeList(Map<String, Object> map);

    // 회원 최근 레시피 조회
    List<RecipeVO> recentlyUserRecipe(int member_id);

    // 전체 최근 레시피 조회 5개만
    List<RecipeVO> recentlyrecipe();

    List<RecipeVO> RecipeList(AdminRecipeDTO adminRecipeDTO);

    // 레시피 게시 상태 변경 함수 아래 update 함수 합칠 예정
    int updateStatus(RecipeVO recipe);

    int updateRecipe(RecipeVO recipe);

    int RecipeCount(AdminRecipeDTO adminRecipeDTO);

    RecipeVO selectrecipe(int recipe_id);

    RecipeDetailDTO getRecipe(int recipeId);

    // 레시피 등록시 (음식 선택 드롭다운용) 전체 음식 목록 조회
    List<Map<String, Object>> selectAllFood();

    List<RecipeVO> selectRecommedList();

    // 레시피 삭제
    int deleteRecipe(int recipeId);

    // 레시피 수정
    void updateNewRecipe(RecipeDTO dto);
    void deleteIngredient(int recipeId);
    void deleteCookOrder(int recipeId);

}
