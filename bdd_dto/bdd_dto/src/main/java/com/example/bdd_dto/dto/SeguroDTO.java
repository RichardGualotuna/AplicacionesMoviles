package com.example.bdd_dto.dto;

public class SeguroDTO {
    private Long id;
    private Double costoTotal;
    private Long automovilId;

    // Constructores
    public SeguroDTO() {}

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Double getCostoTotal() { return costoTotal; }
    public void setCostoTotal(Double costoTotal) { this.costoTotal = costoTotal; }
    public Long getAutomovilId() { return automovilId; }
    public void setAutomovilId(Long automovilId) { this.automovilId = automovilId; }
}