package com.example.bdd_dto.dto;

public class PolizaResponse {
    private String propietario;
    private String modeloAuto;
    private double valorSeguroAuto;
    private int edadPropietario;
    private int accidentes;
    private double costoTotal;

    public PolizaResponse(String propietario, String modeloAuto, double valorSeguroAuto, int edadPropietario, int accidentes, double costoTotal) {
        this.propietario = propietario;
        this.modeloAuto = modeloAuto;
        this.valorSeguroAuto = valorSeguroAuto;
        this.edadPropietario = edadPropietario;
        this.accidentes = accidentes;
        this.costoTotal = costoTotal;
    }

    // Getters
    public String getPropietario() { return propietario; }
    public String getModeloAuto() { return modeloAuto; }
    public double getValorSeguroAuto() { return valorSeguroAuto; }
    public int getEdadPropietario() { return edadPropietario; }
    public int getAccidentes() { return accidentes; }
    public double getCostoTotal() { return costoTotal; }
}
