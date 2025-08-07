package com.example.bdd_dto.service;

import com.example.bdd_dto.dto.SeguroDTO;
import com.example.bdd_dto.model.Automovil;
import com.example.bdd_dto.model.Seguro;
import com.example.bdd_dto.repository.AutomovilRepository;
import com.example.bdd_dto.repository.SeguroRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class SeguroService {
    private final SeguroRepository seguroRepository;
    private final AutomovilRepository automovilRepository;

    public SeguroService(SeguroRepository seguroRepository,
                         AutomovilRepository automovilRepository) {
        this.seguroRepository = seguroRepository;
        this.automovilRepository = automovilRepository;
    }

    // Método para crear un seguro (usado al crear automóvil)
    public SeguroDTO crearSeguro(Long automovilId) {
        Automovil automovil = automovilRepository.findById(automovilId)
                .orElseThrow(() -> new RuntimeException("Automóvil no encontrado"));

        double costoTotal = calcularCostoSeguro(automovil);

        Seguro seguro = new Seguro();
        seguro.setAutomovil(automovil);
        seguro.setCostoTotal(costoTotal);

        Seguro guardado = seguroRepository.save(seguro);
        return convertirADTO(guardado);
    }

    // Método para obtener seguro por ID de automóvil
    public SeguroDTO obtenerPorAutomovilId(Long automovilId) {
        Seguro seguro = seguroRepository.findByAutomovilId(automovilId)
                .orElseThrow(() -> new RuntimeException("Seguro no encontrado para el automóvil con ID: " + automovilId));
        return convertirADTO(seguro);
    }

    // Método para recalcular seguro
    public SeguroDTO recalcular(Long automovilId) {
        Automovil automovil = automovilRepository.findById(automovilId)
                .orElseThrow(() -> new RuntimeException("Automóvil no encontrado"));

        double nuevoCosto = calcularCostoSeguro(automovil);

        Seguro seguro = seguroRepository.findByAutomovilId(automovilId)
                .orElse(new Seguro());

        seguro.setAutomovil(automovil);
        seguro.setCostoTotal(nuevoCosto);

        Seguro actualizado = seguroRepository.save(seguro);
        return convertirADTO(actualizado);
    }

    // Método para eliminar seguro por ID de automóvil
    public void eliminarPorAutomovilId(Long automovilId) {
        seguroRepository.deleteByAutomovilId(automovilId);
    }

    // Método para calcular el costo del seguro según las reglas de negocio
    private double calcularCostoSeguro(Automovil automovil) {
        // Validación de edad del propietario
        if (automovil.getPropietario().getEdad() < 18) {
            throw new RuntimeException("No se puede asegurar a menores de 18 años");
        }

        // 1. Cargo por valor (3.5%)
        double cargoValor = automovil.getValor() * 0.035;

        // 2. Cargo por modelo
        double cargoModelo;
        switch (automovil.getModelo().toUpperCase()) {
            case "A":
                cargoModelo = automovil.getValor() * 0.011;
                break;
            case "B":
                cargoModelo = automovil.getValor() * 0.012;
                break;
            case "C":
                cargoModelo = automovil.getValor() * 0.015;
                break;
            default:
                throw new RuntimeException("Modelo no válido. Debe ser A, B o C");
        }

        // 3. Cargo por edad
        int cargoEdad;
        int edad = automovil.getPropietario().getEdad();
        if (edad >= 18 && edad < 24) {
            cargoEdad = 360;
        } else if (edad >= 24 && edad < 53) {
            cargoEdad = 240;
        } else if (edad >= 53 && edad < 80) {
            cargoEdad = 430;
        } else {
            throw new RuntimeException("Edad no válida para seguro");
        }

        // 4. Cargo por accidentes
        double cargoAccidentes;
        int accidentes = automovil.getAccidentes();
        if (accidentes <= 3) {
            cargoAccidentes = accidentes * 17;
        } else {
            cargoAccidentes = (3 * 17) + ((accidentes - 3) * 21);
        }

        return cargoValor + cargoModelo + cargoEdad + cargoAccidentes;
    }

    // Método para convertir entidad a DTO
    private SeguroDTO convertirADTO(Seguro seguro) {
        SeguroDTO dto = new SeguroDTO();
        dto.setId(seguro.getId());
        dto.setCostoTotal(seguro.getCostoTotal());
        dto.setAutomovilId(seguro.getAutomovil().getId());
        return dto;
    }
}