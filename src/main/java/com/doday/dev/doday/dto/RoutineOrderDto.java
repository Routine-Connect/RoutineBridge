package com.doday.dev.doday.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

@Data
public class RoutineOrderDto {

    @NotNull(message = "루틴 ID는 필수입니다.")
    private Long id;

    @NotNull(message = "순서는 필수입니다.")
    private Integer sortOrder;
}
