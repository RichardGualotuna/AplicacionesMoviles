package com.example.bdd_dto.dto;

import java.util.List;

public class PropietarioDTO {
    private Long id;
    private String nombreCompleto;
    private int edad;
    private List<Long> automovilIds;

    public PropietarioDTO() {
        // Constructor vacío necesario para frameworks como Jackson
    }

    public PropietarioDTO(Long id, String nombreCompleto, int edad, List<Long> automovilIds) {
        this.id = id;
        this.nombreCompleto = nombreCompleto;
        this.edad = edad;
        this.automovilIds = automovilIds;
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getNombreCompleto() {
        return nombreCompleto;
    }
    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }
    public int getEdad() {
        return edad;
    }
    public void setEdad(int edad) {
        this.edad = edad;
    }
    public List<Long> getAutomovilIds() {
        return automovilIds;
    }
    public void setAutomovilIds(List<Long> automovilIds) {
        this.automovilIds = automovilIds;
    }

}
