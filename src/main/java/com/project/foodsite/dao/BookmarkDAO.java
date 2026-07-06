package com.project.foodsite.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.project.foodsite.vo.BookmarkVO;

public interface BookmarkDAO {
    
    List<BookmarkVO> userBookmark(int member_id);

    int countUserBookmark(int member_id);

    List<BookmarkVO> getUserBookmarkList(Map<String, Object> map);    

    BookmarkVO selectbookmark(@Param("recipe_id") int recipe_id, @Param("member_id") int member_id);

    int insertbookmark( BookmarkVO vo );

    int deletebookmark( int bookmark_id );

}
