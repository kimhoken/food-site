package com.project.foodsite.vo;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("ingredient")
public class IngredientVO {
    private int ingredient_id;
    private String ingredient_name;
    private Double quantity;
    private String unit;
    private String type;
    private int recipe_id;
}
