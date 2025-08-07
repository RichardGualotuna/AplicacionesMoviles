package com.example.bdd_dto.controller;

import com.example.bdd_dto.dto.AutomovilDTO;
import com.example.bdd_dto.service.AutomovilService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/automoviles")
public class AutomovilController {

    private final AutomovilService automovilService;

    public AutomovilController(AutomovilService automovilService) {
        this.automovilService = automovilService;
    }

    @PostMapping
    public ResponseEntity<?> crearAutomovil(@RequestBody AutomovilDTO automovilDTO) {
        try {
            AutomovilDTO nuevoAutomovil = automovilService.crear(automovilDTO);
            return new ResponseEntity<>(nuevoAutomovil, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<AutomovilDTO>> obtenerTodosLosAutomoviles() {
        List<AutomovilDTO> automoviles = automovilService.obtenerTodos();
        return ResponseEntity.ok(automoviles);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerAutomovilPorId(@PathVariable Long id) {
        try {
            AutomovilDTO automovil = automovilService.obtenerPorId(id);
            return ResponseEntity.ok(automovil);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarAutomovil(
            @PathVariable Long id,
            @RequestBody AutomovilDTO automovilDTO) {
        try {
            AutomovilDTO actualizado = automovilService.actualizar(id, automovilDTO);
            return ResponseEntity.ok(actualizado);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarAutomovil(@PathVariable Long id) {
        try {
            automovilService.eliminar(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}