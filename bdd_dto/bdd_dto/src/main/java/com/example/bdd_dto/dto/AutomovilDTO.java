package com.example.bdd_dto.dto;

public class AutomovilDTO {
    private Long id;
    private String modelo;
    private Double valor;
    private int accidentes;
    private Long propietarioId;  // ID del propietario para relaciones
    private String propietarioNombreC; // Nombre completo del propietario (formato: "Nombre Apellido")
    private Double costoSeguro;  // Costo calculado del seguro
    private Long seguroId;       // ID del seguro asociado

    // Constructores
    public AutomovilDTO() {
    }

    public AutomovilDTO(Long id, String modelo, Double valor, int accidentes,
                        Long propietarioId, String propietarioNombreC,
                        Double costoSeguro, Long seguroId) {
        this.id = id;
        this.modelo = modelo;
        this.valor = valor;
        this.accidentes = accidentes;
        this.propietarioId = propietarioId;
        this.propietarioNombreC = propietarioNombreC;
        this.costoSeguro = costoSeguro;
        this.seguroId = seguroId;
    }

    // Métodos de acceso (Getters y Setters)
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public Double getValor() {
        return valor;
    }

    public void setValor(Double valor) {
        this.valor = valor;
    }

    public int getAccidentes() {
        return accidentes;
    }

    public void setAccidentes(int accidentes) {
        this.accidentes = accidentes;
    }

    public Long getPropietarioId() {
        return propietarioId;
    }

    public void setPropietarioId(Long propietarioId) {
        this.propietarioId = propietarioId;
    }

    public String getPropietarioNombreC() {
        return propietarioNombreC;
    }

    public void setPropietarioNombreC(String propietarioNombreC) {
        this.propietarioNombreC = propietarioNombreC;
    }

    public Double getCostoSeguro() {
        return costoSeguro;
    }

    public void setCostoSeguro(Double costoSeguro) {
        this.costoSeguro = costoSeguro;
    }

    public Long getSeguroId() {
        return seguroId;
    }

    public void setSeguroId(Long seguroId) {
        this.seguroId = seguroId;
    }

    // Método toString() para representación en texto
    @Override
    public String toString() {
        return "AutomovilDTO{" +
                "id=" + id +
                ", modelo='" + modelo + '\'' +
                ", valor=" + valor +
                ", accidentes=" + accidentes +
                ", propietarioId=" + propietarioId +
                ", propietarioNombreC='" + propietarioNombreC + '\'' +
                ", costoSeguro=" + costoSeguro +
                ", seguroId=" + seguroId +
                '}';
    }

    // Builder pattern para construcción más limpia
    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private Long id;
        private String modelo;
        private Double valor;
        private int accidentes;
        private Long propietarioId;
        private String propietarioNombreC;
        private Double costoSeguro;
        private Long seguroId;

        public Builder id(Long id) {
            this.id = id;
            return this;
        }

        public Builder modelo(String modelo) {
            this.modelo = modelo;
            return this;
        }

        public Builder valor(Double valor) {
            this.valor = valor;
            return this;
        }

        public Builder accidentes(int accidentes) {
            this.accidentes = accidentes;
            return this;
        }

        public Builder propietarioId(Long propietarioId) {
            this.propietarioId = propietarioId;
            return this;
        }

        public Builder propietarioNombreC(String propietarioNombreC) {
            this.propietarioNombreC = propietarioNombreC;
            return this;
        }

        public Builder costoSeguro(Double costoSeguro) {
            this.costoSeguro = costoSeguro;
            return this;
        }

        public Builder seguroId(Long seguroId) {
            this.seguroId = seguroId;
            return this;
        }

        public AutomovilDTO build() {
            return new AutomovilDTO(id, modelo, valor, accidentes,
                    propietarioId, propietarioNombreC,
                    costoSeguro, seguroId);
        }
    }
}