package com.example.bdd_dto.model;

import jakarta.persistence.*;
import java.util.Objects;

@Entity
public class Automovil {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String modelo;
    private Double valor;
    private int accidentes;

    @ManyToOne
    @JoinColumn(name = "propietario_id", nullable = false)
    private Propietario propietario;

    @OneToOne(mappedBy = "automovil", cascade = CascadeType.ALL)
    private Seguro seguro;

    // Constructores
    public Automovil() {}

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getModelo() { return modelo; }
    public void setModelo(String modelo) { this.modelo = modelo; }
    public Double getValor() { return valor; }
    public void setValor(Double valor) { this.valor = valor; }
    public int getAccidentes() { return accidentes; }
    public void setAccidentes(int accidentes) { this.accidentes = accidentes; }
    public Propietario getPropietario() { return propietario; }
    public void setPropietario(Propietario propietario) { this.propietario = propietario; }
    public Seguro getSeguro() { return seguro; }
    public void setSeguro(Seguro seguro) { this.seguro = seguro; }

    // equals y hashCode
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Automovil automovil = (Automovil) o;
        return Objects.equals(id, automovil.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}