package com.example.bdd_dto.service;

import com.example.bdd_dto.dto.AutomovilDTO;
import com.example.bdd_dto.model.Automovil;
import com.example.bdd_dto.model.Propietario;
import com.example.bdd_dto.repository.AutomovilRepository;
import com.example.bdd_dto.repository.PropietarioRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AutomovilService {

    private final AutomovilRepository automovilRepository;
    private final PropietarioRepository propietarioRepository;
    private final SeguroService seguroService;

    public AutomovilService(AutomovilRepository automovilRepository,
                            PropietarioRepository propietarioRepository,
                            SeguroService seguroService) {
        this.automovilRepository = automovilRepository;
        this.propietarioRepository = propietarioRepository;
        this.seguroService = seguroService;
    }

    public AutomovilDTO crear(AutomovilDTO automovilDTO) {
        // Validación del modelo
        if (!esModeloValido(automovilDTO.getModelo())) {
            throw new RuntimeException("Modelo de automóvil no válido. Debe ser A, B o C");
        }

        // Validación del propietario
        Propietario propietario = obtenerPropietarioValido(automovilDTO.getPropietarioId());

        Automovil automovil = new Automovil();
        automovil.setModelo(automovilDTO.getModelo().toUpperCase());
        automovil.setValor(automovilDTO.getValor());
        automovil.setAccidentes(automovilDTO.getAccidentes());
        automovil.setPropietario(propietario);

        Automovil automovilGuardado = automovilRepository.save(automovil);

        // Crear el seguro asociado
        seguroService.crearSeguro(automovilGuardado.getId());

        return convertirADTO(automovilGuardado);
    }

    public List<AutomovilDTO> obtenerTodos() {
        return automovilRepository.findAll().stream()
                .map(this::convertirADTO)
                .collect(Collectors.toList());
    }

    public AutomovilDTO obtenerPorId(Long id) {
        Automovil automovil = automovilRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Automóvil no encontrado con ID: " + id));
        return convertirADTO(automovil);
    }

    public AutomovilDTO actualizar(Long id, AutomovilDTO automovilDTO) {
        Automovil automovilExistente = automovilRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Automóvil no encontrado con ID: " + id));

        // Actualizar modelo si se proporciona y es válido
        if (automovilDTO.getModelo() != null) {
            if (!esModeloValido(automovilDTO.getModelo())) {
                throw new RuntimeException("Modelo de automóvil no válido. Debe ser A, B o C");
            }
            automovilExistente.setModelo(automovilDTO.getModelo().toUpperCase());
        }

        // Actualizar valor si es positivo
        if (automovilDTO.getValor() != null && automovilDTO.getValor() > 0) {
            automovilExistente.setValor(automovilDTO.getValor());
        }

        // Actualizar accidentes si no es negativo
        if (automovilDTO.getAccidentes() >= 0) {
            automovilExistente.setAccidentes(automovilDTO.getAccidentes());
        }

        // Actualizar propietario si se proporciona
        if (automovilDTO.getPropietarioId() != null) {
            Propietario propietario = obtenerPropietarioValido(automovilDTO.getPropietarioId());
            automovilExistente.setPropietario(propietario);
        }

        Automovil automovilActualizado = automovilRepository.save(automovilExistente);

        // Recalcular el seguro
        seguroService.recalcular(automovilActualizado.getId());

        return convertirADTO(automovilActualizado);
    }

    public void eliminar(Long id) {
        if (!automovilRepository.existsById(id)) {
            throw new RuntimeException("Automóvil no encontrado con ID: " + id);
        }
        automovilRepository.deleteById(id);
    }

    private Propietario obtenerPropietarioValido(Long propietarioId) {
        Propietario propietario = propietarioRepository.findById(propietarioId)
                .orElseThrow(() -> new RuntimeException("Propietario no encontrado con ID: " + propietarioId));

        if (propietario.getEdad() < 18) {
            throw new RuntimeException("El propietario debe ser mayor de edad");
        }

        return propietario;
    }

    private boolean esModeloValido(String modelo) {
        return modelo != null && (modelo.equalsIgnoreCase("A") ||
                modelo.equalsIgnoreCase("B") ||
                modelo.equalsIgnoreCase("C"));
    }
    public SeguroService getSeguroService() {
        return this.seguroService;
    }



    private AutomovilDTO convertirADTO(Automovil automovil) {
        AutomovilDTO dto = new AutomovilDTO();
        dto.setId(automovil.getId());
        dto.setModelo(automovil.getModelo());
        dto.setValor(automovil.getValor());
        dto.setAccidentes(automovil.getAccidentes());

        if (automovil.getPropietario() != null) {
            dto.setPropietarioId(automovil.getPropietario().getId());
            dto.setPropietarioNombreC(automovil.getPropietario().getNombre() + " " + automovil.getPropietario().getApellido());
        }

        if (automovil.getSeguro() != null) {
            dto.setCostoSeguro(automovil.getSeguro().getCostoTotal());
            dto.setSeguroId(automovil.getSeguro().getId());
        }

        return dto;
    }
    public AutomovilDTO obtenerPorPropietarioId(Long propietarioId) {
        // Suponiendo que quieres obtener el auto más reciente, puedes usar .findTopBy...OrderByIdDesc
        Automovil auto = automovilRepository.findTopByPropietarioIdOrderByIdDesc(propietarioId)
                .orElseThrow(() -> new RuntimeException("Automóvil no encontrado para el propietario"));

        return convertirADTO(auto);
    }

}