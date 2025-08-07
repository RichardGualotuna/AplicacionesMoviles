package com.example.bdd_dto.repository;

import com.example.bdd_dto.model.Seguro;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SeguroRepository extends JpaRepository<Seguro, Long> {
    Optional<Seguro> findByAutomovilId(Long automovilId);
    void deleteByAutomovilId(Long automovilId);
}