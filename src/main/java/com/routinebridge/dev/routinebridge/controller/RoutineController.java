package com.routinebridge.dev.routinebridge.controller;


import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/routines")
@Api(tags = "Routine", description = "루틴 관리 API")
public class RoutineController {

    @ApiOperation(value = "루틴 생성", notes = "새 루틴 추가")
    @PostMapping
    public void create() {}

    @ApiOperation(value = "루틴 목록 조회", notes = "유저의 전체 루틴 조회")
    @GetMapping
    public void getAll() {}

    @ApiOperation(value = "루틴 수정", notes = "루틴 정보 수정")
    @PutMapping("/{id}")
    public void update(@PathVariable Long id) {}

    @ApiOperation(value = "루틴 삭제", notes = "루틴 삭제")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {}

    @ApiOperation(value = "오늘의 루틴 조회", notes = "오늘 요일에 해당하는 루틴만 조회")
    @GetMapping("/today")
    public void getToday() {}
}
