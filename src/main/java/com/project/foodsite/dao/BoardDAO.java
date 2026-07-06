package com.project.foodsite.dao;

import java.util.List;
import java.util.Map;

import com.project.foodsite.vo.BoardVO;
import com.project.foodsite.vo.CookOrderVO;
import com.project.foodsite.vo.IngredientVO;
import com.project.foodsite.dto.AdminBoardDTO;
import com.project.foodsite.dto.RecipeDTO;

public interface BoardDAO {

    List<BoardVO> selectAll();

    List<BoardVO> search(String search);

    int insertRecipe(RecipeDTO dto);

    BoardVO selectOne(int board_id);

    void updateViewCount(int board_id); // 조회수 증가

    int update(BoardVO vo); // 수정

    int delete(int board_id); // 삭제

    int insertBoard(BoardVO vo); // 커뮤니티 글쓰기

    int insertIngredient(IngredientVO vo); // 재료추가

    int insertCookOrder(CookOrderVO vo); // 조리과정 추가

    int boardCount(AdminBoardDTO Board); // 관리자 페이지 게시글 갯수 조회 (페이징)

    List<AdminBoardDTO> BoardSearch(AdminBoardDTO Board); // 관리자 게시글 조회 및 검색

    AdminBoardDTO adminBoardDetail(int board_id);

    int boardStatus(AdminBoardDTO Board);

    int communityBoardCount();

    List<BoardVO> selectBoardPage(Map<String, Object> map);

    

}
