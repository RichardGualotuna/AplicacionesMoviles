package com.example.bdd_dto.controller;

import com.example.bdd_dto.dto.SeguroDTO;
import com.example.bdd_dto.service.SeguroService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/seguros")
public class SeguroController {

    private final SeguroService seguroService;

    public SeguroController(SeguroService seguroService) {
        this.seguroService = seguroService;
    }

    @GetMapping("/automovil/{automovilId}")
    public ResponseEntity<?> obtenerSeguroPorAutomovilId(@PathVariable Long automovilId) {
        try {
            SeguroDTO seguro = seguroService.obtenerPorAutomovilId(automovilId);
            return ResponseEntity.ok(seguro);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @PostMapping("/recalcular/{automovilId}")
    public ResponseEntity<?> recalcularSeguro(@PathVariable Long automovilId) {
        try {
            SeguroDTO seguro = seguroService.recalcular(automovilId);
            return ResponseEntity.ok(seguro);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/automovil/{automovilId}")
    public ResponseEntity<?> eliminarSeguro(@PathVariable Long automovilId) {
        try {
            seguroService.eliminarPorAutomovilId(automovilId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}