package com.project.foodsite.common;

import lombok.Data;

@Data
public class Paging {
    
    private int page, size, totalcount, totalpage, startpage, endpage, offset;

    // 한 번에 화면에 보여줄 페이지 번호 개수
    private int blocksize =5;

    private boolean prev, next;

    public Paging(int page, int size, int totalcount){
        this.page = page;
        this.size = size;
        this.totalcount = totalcount;
        
        // 전달받은 값을 기준으로 페이징 정보 계산
        pagingcal();        

    }

    public void pagingcal(){

        // 페이지가 0 이하일 경우 첫 페이지로 설정
        page= page <= 0 ? 1: page;

        // 페이지당 출력 개수가 0 이하일 경우 기본값 10으로 설정
        size = size <=0 ? 10 : size;
        
        // 전체 데이터 개수가 음수일 경우 0으로 설정
        totalcount = totalcount < 0 ? 0 : totalcount;

        
        totalpage = (int)Math.ceil((double)totalcount / size);

        if(totalpage == 0 ){
           totalpage = 1;
        }

        if (page > totalpage){
            page = totalpage;
        }

        offset = (page-1) * size;
        
        startpage = ((page-1) / blocksize )* blocksize +1;
        endpage = Math.min(startpage+blocksize -1,totalpage);

        prev = startpage > 1;
        next = endpage < totalpage;  

    }

    
}
