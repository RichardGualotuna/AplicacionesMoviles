package com.example.bdd_dto.controller;

import com.example.bdd_dto.dto.*;
import com.example.bdd_dto.service.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/poliza")
public class PolizaController {

    private final PropietarioService propietarioService;
    private final AutomovilService automovilService;
    private final SeguroService seguroService;

    public PolizaController(PropietarioService propietarioService, AutomovilService automovilService, SeguroService seguroService) {
        this.propietarioService = propietarioService;
        this.automovilService = automovilService;
        this.seguroService = seguroService;
    }

    @PostMapping
    public ResponseEntity<PolizaResponse> crearPoliza(@RequestBody PolizaRequest req) {
        // Crear propietario
        PropietarioDTO propietarioDTO = propietarioService.crear(
                new PropietarioDTO(null, req.getPropietario(), req.getEdadPropietario(), null)
        );

        // Crear auto
        AutomovilDTO autoDTO = new AutomovilDTO(null, req.getModeloAuto(), req.getValorSeguroAuto(),
                req.getAccidentes(), propietarioDTO.getId(), null, null, null);
        autoDTO = automovilService.crear(autoDTO);

        // Obtener seguro
        SeguroDTO seguroDTO = seguroService.obtenerPorAutomovilId(autoDTO.getId());

        // Armar respuesta
        PolizaResponse response = new PolizaResponse(
                propietarioDTO.getNombreCompleto(),
                autoDTO.getModelo(),
                autoDTO.getValor(),
                propietarioDTO.getEdad(),
                autoDTO.getAccidentes(),
                seguroDTO.getCostoTotal()
        );

        return ResponseEntity.ok(response);
    }

    @GetMapping("/usuario")
    public ResponseEntity<PolizaResponse> obtenerPolizaPorNombre(@RequestParam String nombre) {
        // Buscar propietario por nombre
        PropietarioDTO propietarioDTO = propietarioService.buscarPorNombre(nombre);

        // Obtener auto más reciente del propietario (asumimos el último por ID o el primero)
        Long propietarioId = propietarioDTO.getId();
        AutomovilDTO autoDTO = automovilService.obtenerPorPropietarioId(propietarioId);

        // Obtener seguro
        SeguroDTO seguroDTO = seguroService.obtenerPorAutomovilId(autoDTO.getId());

        // Armar respuesta
        PolizaResponse response = new PolizaResponse(
                propietarioDTO.getNombreCompleto(),
                autoDTO.getModelo(),
                autoDTO.getValor(),
                propietarioDTO.getEdad(),
                autoDTO.getAccidentes(),
                seguroDTO.getCostoTotal()
        );

        return ResponseEntity.ok(response);
    }

}
