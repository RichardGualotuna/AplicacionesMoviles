package com.example.bdd_dto.controller;

import com.example.bdd_dto.dto.PropietarioDTO;
import com.example.bdd_dto.service.PropietarioService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/propietarios")
public class PropietarioController {

    private final PropietarioService propietarioService;

    public PropietarioController(PropietarioService propietarioService) {
        this.propietarioService = propietarioService;
    }

    @PostMapping
    public ResponseEntity<?> crearPropietario(@RequestBody PropietarioDTO propietarioDTO) {
        try {
            PropietarioDTO nuevoPropietario = propietarioService.crear(propietarioDTO);
            return new ResponseEntity<>(nuevoPropietario, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<PropietarioDTO>> obtenerTodosLosPropietarios() {
        List<PropietarioDTO> propietarios = propietarioService.obtenerTodos();
        return ResponseEntity.ok(propietarios);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerPropietarioPorId(@PathVariable Long id) {
        try {
            PropietarioDTO propietario = propietarioService.obtenerPorId(id);
            return ResponseEntity.ok(propietario);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarPropietario(
            @PathVariable Long id,
            @RequestBody PropietarioDTO propietarioDTO) {
        try {
            PropietarioDTO actualizado = propietarioService.actualizar(id, propietarioDTO);
            return ResponseEntity.ok(actualizado);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarPropietario(@PathVariable Long id) {
        try {
            propietarioService.eliminar(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}