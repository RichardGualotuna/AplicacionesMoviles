package com.example.bdd_dto.repository;

import com.example.bdd_dto.model.Propietario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PropietarioRepository extends JpaRepository<Propietario, Long> {
    Optional<Propietario> findByNombreAndApellido(String nombre, String apellido);

}
