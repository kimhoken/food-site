package com.project.foodsite.dto;

import java.sql.Date;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@AllArgsConstructor
@NoArgsConstructor
@Alias("adminreview")
public class AdminReviewDTO extends  SearchDTO{
    private Date created_at, updated_at;
    private String title, content, thumbnail, recipe_thumbnail, main_title, nickname;
    private int view_count, review_id;
    private double rating;

}
