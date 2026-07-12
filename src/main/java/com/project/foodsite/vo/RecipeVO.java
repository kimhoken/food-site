package com.project.foodsite.vo;

import java.util.StringTokenizer;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("recipe")
public class RecipeVO {
    //레시피 테이블
    private int recipe_id;
    private String title;
    private String thumbnail;  //이미지
    private String cooking_time;
    private int view_count; //조회수
    private int like_count;
    private double rating; //별점(평점)
    private String status;
    private String created_date; //작성일
    private String updated_date;  //수정일
    private int member_id;
    private int food_id; //음식번호
    private boolean recommend; //추천 레시피 유무
    
    //불러올때 필요한것 추가
    private String nickname;        //member_id로 닉네임 불러옴
    private int score = 0;          //추천시스템에 점수를 저장할 때 사용
    private int rank;
    private String food_name;       //실제 요리명(김치찌개..)
    private int rank_num;
    private String category_name;    
    
    public void addScore(int score){
        this.score += score;
    }

    public int getMin(){
        StringTokenizer st = new StringTokenizer(this.cooking_time, "분");
        String str = st.nextToken();
        if(str.contains("~")){
            st = new StringTokenizer(str, "~");
            return Math.max(Integer.parseInt(st.nextToken()), Integer.parseInt(st.nextToken()));
        }else{
            return Integer.parseInt(str);
        }
    }

}
