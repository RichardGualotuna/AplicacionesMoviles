package com.example.bdd_dto.model;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
public class Seguro {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Double costoTotal;

    @OneToOne
    @JoinColumn(name = "automovil_id", nullable = false)
    private Automovil automovil;

    // Constructores
    public Seguro() {}

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Double getCostoTotal() { return costoTotal; }
    public void setCostoTotal(Double costoTotal) { this.costoTotal = costoTotal; }
    public Automovil getAutomovil() { return automovil; }
    public void setAutomovil(Automovil automovil) { this.automovil = automovil; }

    // equals y hashCode
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Seguro seguro = (Seguro) o;
        return Objects.equals(id, seguro.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}