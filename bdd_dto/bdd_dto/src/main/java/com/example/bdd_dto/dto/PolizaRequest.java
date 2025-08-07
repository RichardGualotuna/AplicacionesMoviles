package com.example.bdd_dto.dto;

public class PolizaRequest {
    private String propietario;
    private double valorSeguroAuto;
    private String modeloAuto;
    private int accidentes;
    private int edadPropietario;

    // Getters y setters
    public String getPropietario() { return propietario; }
    public void setPropietario(String propietario) { this.propietario = propietario; }

    public double getValorSeguroAuto() { return valorSeguroAuto; }
    public void setValorSeguroAuto(double valorSeguroAuto) { this.valorSeguroAuto = valorSeguroAuto; }

    public String getModeloAuto() { return modeloAuto; }
    public void setModeloAuto(String modeloAuto) { this.modeloAuto = modeloAuto; }

    public int getAccidentes() { return accidentes; }
    public void setAccidentes(int accidentes) { this.accidentes = accidentes; }

    public int getEdadPropietario() { return edadPropietario; }
    public void setEdadPropietario(int edadPropietario) { this.edadPropietario = edadPropietario; }
}
