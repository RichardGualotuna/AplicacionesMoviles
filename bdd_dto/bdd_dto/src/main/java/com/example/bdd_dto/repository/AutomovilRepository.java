package com.example.bdd_dto.repository;

import com.example.bdd_dto.model.Automovil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AutomovilRepository extends JpaRepository<Automovil, Long> {
    Optional<Automovil> findTopByPropietarioIdOrderByIdDesc(Long propietarioId);
}